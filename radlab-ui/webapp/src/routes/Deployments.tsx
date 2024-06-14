import RouteContainer from "@/components/RouteContainer"
import { useEffect, useState } from "react"
import { DEPLOYMENT_HEADERS } from "@/utils/data"
import ModuleDeployment from "@/components/modules/ModuleDeployment"
import {
  SORT_DIRECTION,
  SORT_FIELD,
  Deployments as DeploymentsParser,
  IDeployment,
  Modules,
} from "@/utils/types"
import { useTranslation } from "next-i18next"
import { classNames } from "@/utils/dom"
import axios from "axios"
import {
  alertStore,
  deploymentStore,
  moduleNamesStore,
  userStore,
} from "@/store"
import Loading from "@/navigation/Loading"
import { ALERT_TYPE } from "@/utils/types"
import AdminSettingsButton from "@/components/AdminSettingsButton"
import NewDeploymentButton from "@/components/NewDeploymentButton"
import EmptyAdminState from "@/components/EmptyAdminState"
import EmptyState from "@/components/EmptyState"
import Filter from "@/components/Filter"

enum DEPLOYMENT_TAB {
  ALL,
  MINE,
}

interface DeploymentsProps {}

const Deployments: React.FC<DeploymentsProps> = () => {
  const { t } = useTranslation()
  const [listAllDeployments, setAllList] = useState<IDeployment[] | null>(null)
  const [listMyDeployments, setMyList] = useState<IDeployment[] | null>(null)
  const { isAdmin, user } = userStore((state) => state)
  const [isLoading, setLoading] = useState(true)
  const setAlert = alertStore((state) => state.setAlert)
  const [deploymentTab, setDeploymentTab] = useState(
    isAdmin ? DEPLOYMENT_TAB.ALL : DEPLOYMENT_TAB.MINE,
  )
  const setDeployments = deploymentStore((state) => state.setDeployments)
  const filteredDeployments = deploymentStore(
    (state) => state.filteredDeployments,
  )
  const setFilteredDeployments = deploymentStore(
    (state) => state.setFilteredDeployments,
  )
  const setModuleNames = moduleNamesStore((state) => state.setModuleNames)

  const [clearFilter, setClearFilter] = useState(false)
  const [refresh, setRefresh] = useState(false)

  const fetchData = async () => {
    Promise.all([
      axios.get(`/api/deployments`),
      axios.get(`/api/deployments?deployedByEmail=${user?.email}`),
    ])
      .then(([deployRes, adminDeployRes]) => {
        const allDeployData = DeploymentsParser.parse(
          deployRes.data.deployments,
        )
        const myDeployData = DeploymentsParser.parse(
          adminDeployRes.data.deployments,
        )
        setAllList(allDeployData)
        setMyList(myDeployData)
        deploymentTab === DEPLOYMENT_TAB.ALL
          ? setDeployments(allDeployData)
          : setDeployments(myDeployData)
        deploymentTab === DEPLOYMENT_TAB.ALL
          ? setFilteredDeployments(allDeployData)
          : setFilteredDeployments(myDeployData)
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: t("error"),
          durationMs: 10000,
          type: ALERT_TYPE.ERROR,
        })
      })
      .finally(() => {
        setLoading(false)
      })
  }

  const fetchModules = async () => {
    setLoading(true)
    await axios
      .get("/api/modules")
      .then((res) => {
        const modules = Modules.parse(res.data.modules)
        setModuleNames(modules)
      })
      .catch((err) => {
        console.error(err)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  const handleRefresh = (state: boolean) => setRefresh(state)

  useEffect(() => {
    fetchData()
    fetchModules()
  }, [deploymentTab, refresh])

  const renderAllTab = () => {
    return (
      <a
        className={classNames(
          "w-1/2 text-xs md:text-sm lg:text-base tab md:tab-lg",
          deploymentTab === DEPLOYMENT_TAB.ALL ? "tab-active" : "",
        )}
        data-testid="all-deployments"
        onClick={() => {
          setDeploymentTab(DEPLOYMENT_TAB.ALL),
            setFilteredDeployments(null),
            setClearFilter(true)
        }}
      >
        {t("all-deployments")}
      </a>
    )
  }

  const renderMyTab = () => {
    return (
      <a
        className={classNames(
          "w-1/2 text-xs md:text-sm lg:text-base tab md:tab-lg",
          deploymentTab === DEPLOYMENT_TAB.MINE ? "tab-active" : "",
        )}
        data-testid="my-deployments"
        onClick={() => {
          setDeploymentTab(DEPLOYMENT_TAB.MINE),
            setFilteredDeployments(null),
            setClearFilter(true)
        }}
      >
        {t("my-deployments")}
      </a>
    )
  }

  const renderEmptyState = () => {
    return isAdmin ? <EmptyAdminState /> : <EmptyState />
  }

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      <div className="flex mb-2">
        <div className="w-full">
          <div className="tabs tabs-boxed">
            {renderMyTab()}
            {isAdmin && renderAllTab()}
          </div>
        </div>
        <div className="w-full text-right">
          {deploymentTab === DEPLOYMENT_TAB.ALL && (
            <AdminSettingsButton
              text={t("admin-settings")}
              data-testid="admin-settings"
            />
          )}
          {deploymentTab === DEPLOYMENT_TAB.MINE && (
            <NewDeploymentButton
              text={t("create-new")}
              data-testid="create-new"
            />
          )}
        </div>
      </div>
      <Filter filters={["status", "module"]} clearFilter={clearFilter} />
      {deploymentTab === DEPLOYMENT_TAB.ALL &&
        (listAllDeployments?.length ? (
          <ModuleDeployment
            headers={DEPLOYMENT_HEADERS}
            deployments={filteredDeployments || listAllDeployments}
            defaultSortField={SORT_FIELD.CREATEDAT}
            defaultSortDirection={SORT_DIRECTION.DESC}
            handleRefresh={handleRefresh}
          />
        ) : (
          renderEmptyState()
        ))}
      {deploymentTab === DEPLOYMENT_TAB.MINE &&
        (listMyDeployments?.length ? (
          <ModuleDeployment
            headers={DEPLOYMENT_HEADERS}
            deployments={filteredDeployments || listMyDeployments}
            defaultSortField={SORT_FIELD.CREATEDAT}
            defaultSortDirection={SORT_DIRECTION.DESC}
            handleRefresh={handleRefresh}
          />
        ) : (
          renderEmptyState()
        ))}
    </RouteContainer>
  )
}

export default Deployments
