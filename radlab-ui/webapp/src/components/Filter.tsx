import Search, { ISearchResults } from "@/components/Search"
import { useEffect, useRef, useState } from "react"
import { useTranslation } from "next-i18next"
import { DEPLOYMENT_STATUS, IDeployment, IModule } from "@/utils/types"
import { deploymentStore } from "@/store"

type IFilterType = "module" | "createdAt" | "status"
type IModuleName = string | ""
type IDate = typeof DEPLOYMENT_STATUS | string | ""

export default function Filter({
  filters,
  statuses,
  defaultStatus,
  modules,
}: {
  filters: IFilterType[]
  statuses: typeof DEPLOYMENT_STATUS
  defaultStatus?: typeof DEPLOYMENT_STATUS
  modules: IModule[] | null
}) {
  const inputRef = useRef(null)
  const [search, setSearch] = useState<ISearchResults | null>(null)
  const [status, setStatus] = useState(defaultStatus || "")
  const [moduleName, setModuleName] = useState<IModuleName>("")
  const [date, setDate] = useState<IDate>("")

  const { t } = useTranslation()

  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const deployments = deploymentStore((state) => state.deployments)

  // TODO. Likely change this to the firebase.uid for the record
  const refField = "name"
  const handleQuery = (search: ISearchResults) => {
    setSearch(search)
  }

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
    if (!search?.query && status === "" && moduleName === "" && date === "") {
      setFilteredDeployments(null)
      return
    }

    let filtered = deployments

    if (search?.query) {
      // @ts-ignore TS is wrong about possible type (can't be udefined[] because of filter(Boolean) step)
      filtered = search.result
        .sort((a, b) => b.score - a.score)
        .map((result) => result.ref)
        .map((ref) =>
          // @ts-ignore
          deployments.find((deployment) => deployment[refField] === ref),
        )
        .filter(Boolean)
    }

    // if (status !== "")
    //   // @ts-ignore
    //   filtered = filtered.filter((demo) => demo.onboarding.status === status)
    if (moduleName !== "")
      filtered = filtered.filter(
        (deployments) => deployments.module === moduleName,
      )
    // if (date !== "")
    //   filtered = filtered.filter((demo) => demo.vertical === vertical)
    // if (owner === "Google")
    //   filtered = filtered.filter((demo) => !demo.hasOwnProperty("partnerId"))
    // if (owner !== "" && owner !== "Google")
    //   filtered = filtered.filter((demo) => demo.hasOwnProperty("partnerId"))

    setFilteredDeployments(filtered)
  }, [moduleName, deployments, search])

  const clearAllFilters = () => {
    // @ts-ignore
    //inputRef.current.value = ""
    // console.log("module name", moduleName)
    setSearch(null)
    setModuleName("")
  }

  return (
    <div className="w-full bg-base-200 p-2">
      <Search
        inputRef={inputRef}
        placeholder="Search by module name or status"
        // @ts-ignore
        documents={deployments}
        refField={refField}
        handleQuery={handleQuery}
      />

      <div className="grid grid-cols-4 lg:grid-cols-8 gap-4 mt-4">
        {/* {filters.includes("status") && (
          <select
            onChange={(e) => setStatus(e.target.value)}
            value={status}
            className="select col-span-2"
          >
            <option value="">{t("onboarding-status")}</option>
            {statuses.map((status) => (
              <option key={status}>{status}</option>
            ))}
          </select>
        )} */}

        {filters.includes("module") && (
          <select
            onChange={(e) => setModuleName(e.target.value)}
            // @ts-ignore
            value={moduleName}
            className="select col-span-2"
          >
            <option value="">{t("module-name")}</option>
            {modules?.map((module, index) => (
              <option key={index}>{module.name}</option>
            ))}
          </select>
        )}
        {/* 
        {filters.includes("vertical") && (
          <select
            onChange={(e) => setVertical(e.target.value)}
            value={vertical}
            className="select col-span-2"
          >
            <option value="">{t("vertical")}</option>
            {DemoVerticals.map((vertical) => (
              <option key={vertical}>{vertical}</option>
            ))}
          </select>
        )}

        {filters.includes("owner") && (
          <select
            onChange={(e) => setOwner(e.target.value)}
            value={owner}
            className="select col-span-1"
          >
            <option value="">{t("owner")}</option>
            {OWNERS.map((owner) => (
              <option key={owner}>{owner}</option>
            ))}
          </select>
        )} */}

        <button className="btn btn-outline" onClick={clearAllFilters}>
          {t("clear")}
        </button>
      </div>
    </div>
  )
}
