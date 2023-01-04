import Search, { ISearchResults } from "@/components/Search"
import { useEffect, useRef, useState } from "react"
import { useTranslation } from "next-i18next"
import { DEPLOYMENT_STATUS, IModule } from "@/utils/types"
import { deploymentStore } from "@/store"

type IFilterType = "module" | "createdAt" | "status"
type IModuleName = string | ""
type IDate = string | ""

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
  const [createdAt, setCreatedAt] = useState<IDate>("")

  const { t } = useTranslation()

  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const deployments = deploymentStore((state) => state.deployments)

  // TODO. Likely change this to the firebase.uid for the record
  const refField = "deploymentId"
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
    if (
      !search?.query &&
      status === "" &&
      moduleName === "" &&
      createdAt === ""
    ) {
      setFilteredDeployments(null)
      return
    }

    let filtered = deployments

    if (search?.query) {
      // @ts-ignore TS is wrong about possible type (can't be udefined[] because of filter(Boolean) step)
      filtered = search.result
        .sort((a, b) => b.score - a.score)
        .map((result) => result.ref)
        .map((ref) => {
          // @ts-ignore
          return deployments.find((deployment) => deployment[refField] === ref)
        })
        .filter(Boolean)
    }

    if (status !== "") {
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

    if (createdAt !== "") {
      filtered = filtered.filter(
        (deployment) =>
          new Date(
            deployment.createdAt._seconds * 1000 +
              deployment.createdAt._nanoseconds / 1000000,
          ).toLocaleDateString() === createdAt,
      )
    }

    setFilteredDeployments(filtered)
  }, [moduleName, deployments, search, status, createdAt])

  const clearAllFilters = () => {
    // @ts-ignore
    inputRef.current.value = ""
    setSearch(null)
    setModuleName("")
    setStatus("")
    setCreatedAt("")
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
            onChange={(e) =>
              setCreatedAt(new Date(e.target.value).toLocaleDateString())
            }
          />
        )}
        {filters.includes("createdAt") && (
          <input
            className="rounded-md  border-base-300"
            type="date"
            placeholder="End date"
            onChange={(e) =>
              setCreatedAt(new Date(e.target.value).toLocaleDateString())
            }
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
