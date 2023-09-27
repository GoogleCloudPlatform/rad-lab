import Search, { ISearchResults } from "@/components/Search"
import Loading from "@/navigation/Loading"
import { deploymentStore, moduleNamesStore } from "@/store"
import { DEPLOYMENT_STATUSES } from "@/utils/data"
import { startCase } from "lodash"
import { useTranslation } from "next-i18next"
import { useEffect, useRef, useState } from "react"

type IFilterType =
  | "module"
  | "deploymentId"
  | "deployedByEmail"
  | "createdAt"
  | "status"

export default function Filter({
  filters,
}: {
  filters: IFilterType[]
  clearFilter: boolean
}) {
  const deployments = deploymentStore((state) => state.deployments)
  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const inputRef = useRef(null)
  const [search, setSearch] = useState<ISearchResults | null>(null)
  const [status, setStatus] = useState("Deleted")
  const [moduleName, setModuleName] = useState<string>("")
  const statuses = DEPLOYMENT_STATUSES
  const { t } = useTranslation()

  const moduleNames = moduleNamesStore((state) => state.moduleNames)
  const [isLoading, _] = useState<boolean>(false)

  // TODO. Likely change this to the firebase.uid for the record
  const refField = "id"
  const handleQuery = (search: ISearchResults) => setSearch(search)

  // Filter based on Selects and Search

  useEffect(() => {
    setStatus("Deleted")
    if (!deployments) {
      setFilteredDeployments(null)
      return
    }

    //No active filtering happening
    if (
      !search?.query &&
      status === "" &&
      moduleName === ""
      // category === "" &&
      // classification === ""
    ) {
      setFilteredDeployments(null)
      return
    }

    deployments.map((deployment) => {
      if (deployment.hasOwnProperty("deletedAt")) {
        //@ts-ignore
        deployment["status"] = "DELETED"
      }
    })
    let filtered = deployments

    if (search?.query) {
      // @ts-ignore TS is wrong about possible type (can't be udefined[] because of filter(Boolean) step)
      filtered = search.result
        .sort((a, b) => b.score - a.score)
        .map((result) => result.ref)
        .map((ref) =>
          deployments.find((deployment) => deployment[refField] === ref),
        )
        .filter(Boolean)
    }

    setFilteredDeployments(filtered)
  }, [deployments, search, moduleName])

  const clearAllFilters = () => {
    // @ts-ignore
    inputRef.current.value = ""
    setSearch(null)
  }

  if (isLoading) return <Loading />

  return (
    <div className="w-full">
      <Search
        inputRef={inputRef}
        placeholder="Search by Module or Project ID or Deployment ID"
        // @ts-ignore
        documents={deployments}
        refField={refField}
        handleQuery={handleQuery}
      />

      <div className="grid grid-cols-2 lg:grid-cols-10 gap-4 mt-4">
        {filters.includes("status") && (
          <select
            onChange={(e) => setStatus(e.target.value)}
            className="select select-bordered w-full max-w-xs col-span-4"
          >
            <option disabled selected>
              {t("status")}
            </option>
            {statuses.map((status) => {
              const statusValue = status.toLowerCase()
              return (
                <>
                  <input
                    type="checkbox"
                    //@ts-ignore
                    checked="checked"
                    className="checkbox checkbox-sm"
                  />
                  <option key={statusValue} value={statusValue}>
                    {startCase(statusValue)}
                  </option>
                </>
              )
            })}
          </select>
        )}

        {filters.includes("module") && (
          <select
            onChange={(e) => setModuleName(e.target.value)}
            className="select select-bordered w-full max-w-xs col-span-4"
          >
            <option value="">{t("modules")}</option>
            {moduleNames &&
              moduleNames.length &&
              moduleNames.map((module) => {
                return (
                  <option key={module.name}>{startCase(module.name)}</option>
                )
              })}
          </select>
        )}
        <div className="flex justify-end col-span-2">
          <button
            className="btn btn-link no-underline hover:no-underline btn-md bg-primary bg-opacity-80 text-base-100 hover:bg-opacity-90 hover:bg-primary"
            onClick={clearAllFilters}
          >
            {t("clear")}
          </button>
        </div>
      </div>
    </div>
  )
}
