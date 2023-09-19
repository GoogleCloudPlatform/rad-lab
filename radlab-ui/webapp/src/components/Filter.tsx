import Search, { ISearchResults } from "@/components/Search"
import { deploymentStore } from "@/store"
import { DEPLOYMENT_STATUSES } from "@/utils/data"
import { useTranslation } from "next-i18next"
import { useEffect, useRef, useState } from "react"

type IFilterType =
  | "module"
  | "deploymentId"
  | "deployedByEmail"
  | "createdAt"
  | "status"
// type ICategory = (typeof DemoCategories)[number] | string | ""
// type IVerticals = (typeof DemoCategories)[number] | string | ""

export default function Filter({ filters }: { filters: IFilterType[] }) {
  const deployments = deploymentStore((state) => state.deployments)
  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const inputRef = useRef(null)
  const [search, setSearch] = useState<ISearchResults | null>(null)
  const [status, setStatus] = useState("Deleted")
  const [moduleName, setModuleName] = useState<string>("")
  const { t } = useTranslation()
  const statuses = DEPLOYMENT_STATUSES
  // const [category, setCategory] = useState<string>("")
  // const [classification, setClassification] = useState("")

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

    // if (status !== "")
    //   // @ts-ignore
    //   filtered = filtered.filter((demo) => demo.status === status)
    // if (category !== "")
    //   filtered = filtered.filter((demo) => demo.category === category)
    // if (vertical !== "")
    //   filtered = filtered.filter(
    //     (demo) =>
    //       demo.vertical === vertical || demo.vertical.includes("Security"),
    //   )
    // if (classification !== "")
    //   // @ts-ignore
    //   filtered = filtered.filter((demo) =>
    //     classification === "demo"
    //       ? demo.classification === "demo" || demo.classification === undefined
    //       : demo.classification === "solution",
    //   )

    setFilteredDeployments(filtered)
  }, [deployments, search, moduleName])

  // const clearAllFilters = () => {
  //   // @ts-ignore
  //   inputRef.current.value = ""
  //   setSearch(null)
  //   setStatus("")
  //   setVertical("")
  //   setCategory("")
  //   setClassification("")
  // }

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

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
        {filters.includes("status") && (
          <select
            onChange={(e) => setStatus(e.target.value)}
            value={status}
            className="select select-bordered w-full max-w-xs"
          >
            <option value={status} className="text-xs">
              {status}
            </option>
            {statuses.map((status) => (
              <option key={status} className="text-xs">
                {status}
              </option>
            ))}
          </select>
        )}

        {/* {filters.includes("category") && (
          <select
            onChange={(e) => setCategory(e.target.value)}
            value={category}
            className="select col-span-2"
          >
            <option value="">{t("category")}</option>
            {DemoCategories.map((category) => (
              <option key={category}>{category}</option>
            ))}
          </select>
        )} */}
      </div>
      {/* <div className="flex justify-end mt-2">
        <button className="btn btn-outline btn-sm" onClick={clearAllFilters}>
          Clear
        </button>
      </div> */}
    </div>
  )
}
