import { BaseFeatureDataAdapter } from '@jbrowse/core/data_adapters/BaseAdapter'
import { doesIntersect2, SimpleFeature } from '@jbrowse/core/util'
import { openLocation } from '@jbrowse/core/util/io'
import { ObservableCreate } from '@jbrowse/core/util/rxjs'
import { readFile, parseBed } from '../util'
import type { BaseOptions } from '@jbrowse/core/data_adapters/BaseAdapter'
import type { Feature, Region } from '@jbrowse/core/util'

interface BareFeature {
  strand: number
  refName: string
  start: number
  end: number
  score: number
  name: string
}

type Row = [BareFeature, BareFeature, number, number]

export default class MCScanAnchorsAdapter extends BaseFeatureDataAdapter {
  private setupP?: Promise<{
    assemblyNames: string[]
    feats: Row[]
  }>

  public static capabilities = ['getFeatures', 'getRefNames']

  async setup(opts: BaseOptions) {
    if (!this.setupP) {
      this.setupP = this.setupPre(opts).catch((e: unknown) => {
        this.setupP = undefined
        throw e
      })
    }
    return this.setupP
  }
  async setupPre(opts: BaseOptions) {
    const assemblyNames = this.getConf('assemblyNames') as string[]

    const pm = this.pluginManager
    const bed1 = openLocation(this.getConf('bed1Location'), pm)
    const bed2 = openLocation(this.getConf('bed2Location'), pm)
    const mcscan = openLocation(this.getConf('mcscanAnchorsLocation'), pm)
    const [bed1text, bed2text, mcscantext] = await Promise.all(
      [bed1, bed2, mcscan].map(r => readFile(r, opts)),
    )

    const bed1Map = parseBed(bed1text!)
    const bed2Map = parseBed(bed2text!)
    const feats = mcscantext!
      .split(/\n|\r\n|\r/)
      .filter(f => !!f && f !== '###')
      .map((line, index) => {
        const [name1, name2, score] = line.split('\t')
        const r1 = bed1Map.get(name1)
        const r2 = bed2Map.get(name2)
        if (!r1 || !r2) {
          throw new Error(`feature not found, ${name1} ${name2} ${r1} ${r2}`)
        }
        return [r1, r2, +score!, index] as Row
      })

    return {
      assemblyNames,
      feats,
    }
  }

  async hasDataForRefName() {
    // determining this properly is basically a call to getFeatures so is not
    // really that important, and has to be true or else getFeatures is never
    // called (BaseFeatureDataAdapter filters it out)
    return true
  }

  getAssemblyNames() {
    const assemblyNames = this.getConf('assemblyNames') as string[]
    return assemblyNames
  }

  async getRefNames(opts: BaseOptions = {}) {
    // @ts-expect-error
    const r1 = opts.regions?.[0].assemblyName
    const { feats } = await this.setup(opts)

    const idx = this.getAssemblyNames().indexOf(r1)
    if (idx !== -1) {
      const set = new Set<string>()
      for (const feat of feats) {
        set.add(idx === 0 ? feat[0].refName : feat[1].refName)
      }
      return [...set]
    }
    console.warn('Unable to do ref renaming on adapter')
    return []
  }

  getFeatures(region: Region, opts: BaseOptions = {}) {
    return ObservableCreate<Feature>(async observer => {
      const { assemblyNames, feats } = await this.setup(opts)

      // The index of the assembly name in the region list corresponds to
      // the adapter in the subadapters list
      const index = assemblyNames.indexOf(region.assemblyName)
      if (index !== -1) {
        const flip = index === 0
        feats.forEach(f => {
          const [r1, r2, score, rowNum] = f
          const [f1, f2] = !flip ? [r2, r1] : [r1, r2]
          if (
            f1.refName === region.refName &&
            doesIntersect2(region.start, region.end, f1.start, f1.end)
          ) {
            observer.next(
              new SimpleFeature({
                ...f1,
                uniqueId: `${index}-${rowNum}`,
                syntenyId: rowNum,

                // note: strand would be -1 if the two features are on opposite
                // strands, indicating inverted alignment
                strand: f1.strand * f2.strand,
                assemblyName: assemblyNames[+!flip],
                score,
                mate: {
                  ...f2,
                  assemblyName: assemblyNames[+flip],
                },
              }),
            )
          }
        })
      }

      observer.complete()
    })
  }

  /**
   * called to provide a hint that data tied to a certain region
   * will not be needed for the foreseeable future and can be purged
   * from caches, etc
   */
  freeResources(/* { region } */): void {}
}