import Search, { ISearchResults } from "@/components/Search"
import { useEffect, useRef, useState } from "react"
import { useTranslation } from "next-i18next"
import { DEPLOYMENT_STATUS, FirestoreTimestamp, IModule } from "@/utils/types"
import { deploymentStore } from "@/store"

type IFilterType = "module" | "createdAt" | "status"
type IModuleName = string | ""
type IDate = typeof FirestoreTimestamp

export default function Filter({
  filters,
  statuses,
  defaultStatus,
  modules,
}: {
  filters: IFilterType[]
  statuses: typeof DEPLOYMENT_STATUS[]
  defaultStatus?: typeof DEPLOYMENT_STATUS
  modules: IModule[] | null
}) {
  const inputRef = useRef(null)
  const [search, setSearch] = useState<ISearchResults | null>(null)
  const [status, setStatus] = useState(defaultStatus || "")
  const [moduleName, setModuleName] = useState<IModuleName>("")
  // const [createdAt, setCreatedAt] = useState<IDate | null>(null)

  const { t } = useTranslation()

  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const deployments = deploymentStore((state) => state.deployments)

  // TODO. Likely change this to the firebase.uid for the record
  const refField = "module"
  const handleQuery = (search: ISearchResults) => setSearch(search)

  // Owner Filter list
  // const loginPartnerName = partner?.name
  // const OWNERS = ["Google", loginPartnerName]

  // Filter based on Selects and Search
  useEffect(() => {
    if (!deployments) {
      setFilteredDeployments(null)
      return
    }

    //No active filtering happening
    if (!search?.query && status === "" && moduleName === "") {
      setFilteredDeployments(null)
      return
    }

    let filtered = deployments

    if (search?.query) {
      filtered = filtered.filter(
        (e) =>
          e.module.toLowerCase().startsWith(search.query.toLowerCase()) ||
          (e.status.toLowerCase().startsWith(search.query.toLowerCase()) &&
            !e.deletedAt),
      )
      // @ts-ignore TS is wrong about possible type (can't be udefined[] because of filter(Boolean) step)
      // filtered = search.result
      //   // .sort((a, b) => b.score - a.score)
      //   // .map((result) => result.ref)
      //   // .map((ref) =>
      //   //   // @ts-ignore
      //   //   deployments.find((deployment) => deployment[refField] === ref),
      //   // )

      //   .filter(Boolean)
    }

    if (status !== "") {
      // @ts-ignore
      status !== "DELETED"
        ? (filtered = filtered.filter(
            (deployment) =>
              deployment.status === status && !deployment.deletedAt,
          ))
        : (filtered = filtered.filter((deployment) => deployment.deletedAt))
    }

    if (moduleName !== "")
      filtered = filtered.filter(
        (deployments) => deployments.module === moduleName,
      )
    // if (!createdAt)
    //   filtered = filtered.filter(
    //     (deployment) => deployment.createdAt === createdAt,
    //   )
    // if (owner === "Google")
    //   filtered = filtered.filter((demo) => !demo.hasOwnProperty("partnerId"))
    // if (owner !== "" && owner !== "Google")
    //   filtered = filtered.filter((demo) => demo.hasOwnProperty("partnerId"))

    setFilteredDeployments(filtered)
  }, [moduleName, deployments, search, status])

  const clearAllFilters = () => {
    // @ts-ignore
    inputRef.current.value = ""
    setSearch(null)
    setModuleName("")
    setStatus("")
  }

  return (
    <div className="w-full bg-base-100 p-2">
      <Search
        inputRef={inputRef}
        placeholder={t("search_module_or_status")}
        // @ts-ignore
        documents={deployments}
        refField={refField}
        handleQuery={handleQuery}
      />

      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mt-4">
        {filters.includes("module") && (
          <select
            onChange={(e) => setModuleName(e.target.value)}
            // @ts-ignore
            value={moduleName}
            className="select select-bordered w-full max-w-xs"
          >
            <option value="">{t("module-name")}</option>
            {modules?.map((module, index) => (
              <option key={index}>{module.name}</option>
            ))}
          </select>
        )}
        {filters.includes("status") && (
          <select
            onChange={(e) => setStatus(e.target.value)}
            // @ts-ignore
            value={status}
            className="select select-bordered w-full max-w-xs"
          >
            <option value="">{t("status")}</option>
            {statuses.map((status, index) => (
              <option key={index}>{status}</option>
            ))}
          </select>
        )}
        {filters.includes("createdAt") && (
          <input
            className="rounded-md border-base-300"
            type="date"
            placeholder="Start Date"
          />
        )}
        {filters.includes("createdAt") && (
          <input
            className="rounded-md  border-base-300"
            type="date"
            placeholder="End date"
          />
        )}

        <div className="md:text-right">
          <button
            className="btn btn-outline btn-md w-1/2"
            onClick={clearAllFilters}
          >
            {t("clear")}
          </button>
        </div>
      </div>
    </div>
  )
}
