import { IRegion } from "@/utils/types"
import axios from "axios"
import { alphabetically } from "@/utils/sorting"

const getRegionZoneList = () => {
  return axios
    .get(`/api/regions`)
    .then((res) => {
      return res.data.regions as IRegion[]
    })
    .catch((error) => {
      console.error(error)
      return []
    })
}

export class CloudLocation {
  private _regions: IRegion[] | null

  constructor() {
    this._regions = null
  }

  get regions() {
    if (this._regions) {
      return Promise.resolve(this._regions)
    }

    return getRegionZoneList().then((regions) => {
      this._regions = regions
      return regions
    })
  }

  get regionNames() {
    return this.regions.then((regions) =>
      regions.map((r) => r.name).sort(alphabetically),
    )
  }

  get zones() {
    return this.regions.then((regions) =>
      regions
        .map((r) => r.zones)
        .flat()
        .sort(alphabetically),
    )
  }

  zonesByRegion(regionName: string) {
    return this.regions.then((regions) =>
      (regions.find((r) => r.name === regionName)?.zones ?? []).sort(
        alphabetically,
      ),
    )
  }
}
