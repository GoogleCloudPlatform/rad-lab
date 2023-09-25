import React, { useEffect, useState } from "react"
import {
  ChevronDownIcon,
  ChevronUpIcon,
  TrashIcon,
} from "@heroicons/react/outline"
import { textColorFromDeployStatus } from "@/utils/deployments"
import { classNames } from "@/utils/dom"
import {
  SORT_DIRECTION,
  SORT_FIELD,
  IHeader,
  FirestoreTimestamp,
  IDeployment,
  DEPLOYMENT_STATUS,
} from "@/utils/types"
import { useNavigate } from "react-router-dom"
import startCase from "lodash/startCase"
import ProjectLink from "@/components/ProjectLink"
import { useTranslation } from "next-i18next"
import DeleteDeploymentModal from "@/components/DeleteDeploymentModal"

interface ModuleDeploymentProps {
  deployments: IDeployment[] | null
  defaultSortField?: SORT_FIELD
  defaultSortDirection?: SORT_DIRECTION
  headers: IHeader[]
}

const ModuleDeployment: React.FC<ModuleDeploymentProps> = ({
  deployments,
  defaultSortField,
  defaultSortDirection,
  headers,
}) => {
  const [sortField, setSortField] = useState<SORT_FIELD>(
    defaultSortField || SORT_FIELD.MODULE,
  )
  const [sortDirection, setSortDirection] = useState<SORT_DIRECTION>(
    defaultSortDirection || SORT_DIRECTION.DESC,
  )
  // const [isMultipleSelect, setMultipleSelect] = useState<boolean>(false)
  const [isAllSelect, setAllSelect] = useState<boolean>(false)
  const [isModal, setModal] = useState<boolean>(false)
  const { t } = useTranslation()
  const [deploymentId, setDeploymentId] = useState<string[]>([])

  const setSort = (header: IHeader) => () => {
    if (header.field === sortField) {
      setSortDirection(
        sortDirection === SORT_DIRECTION.ASC
          ? SORT_DIRECTION.DESC
          : SORT_DIRECTION.ASC,
      )
    } else {
      setSortField(header.field)
      setSortDirection(header.direction)
    }
  }
  const tableSort = (a: IDeployment, b: IDeployment) => {
    if (a[sortField] === undefined && b[sortField] === undefined) return 0

    // Put undefined values at the bottom always
    if (a[sortField] === undefined) return 1
    if (b[sortField] === undefined) return -1

    let valueA: string | number | FirestoreTimestamp | undefined
    let valueB: string | number | FirestoreTimestamp | undefined

    valueA = a[sortField]
    valueB = b[sortField]

    // Check if values are Firestore Timestamps
    if (typeof valueA !== "string" && typeof valueA !== "number") {
      valueA = valueA?._seconds
    }
    if (typeof valueB !== "string" && typeof valueB !== "number") {
      valueB = valueB?._seconds
    }

    if (typeof valueA === "string") valueA = valueA.toLowerCase()
    if (typeof valueB === "string") valueB = valueB.toLowerCase()

    if (valueA === valueB) return 0

    if (sortDirection === SORT_DIRECTION.ASC) {
      // @ts-ignore
      if (valueA > valueB) return 1
      return -1
    }

    if (sortDirection === SORT_DIRECTION.DESC) {
      // @ts-ignore
      if (valueA < valueB) return 1
      return -1
    }

    return 0
  }
  const navigate = useNavigate()

  const handleDeployment =
    (deployment: IDeployment) => (e: React.SyntheticEvent) => {
      const id = e.currentTarget.getAttribute("data-id")
      navigate(`/deployments/${id}`, { state: { deployment } })
    }

  const handleAllCheckBox = (deployments: IDeployment[], select: boolean) => {
    setAllSelect(select)
    select
      ? deployments
          .filter((item) => item.status === DEPLOYMENT_STATUS.SUCCESS)
          .map((deployment) => {
            setDeploymentId((oldArray) => [
              ...oldArray,
              deployment.deploymentId,
            ])
          })
      : setDeploymentId([])
  }

  const handleClick = (state: boolean) => setModal(state)

  const renderModal = () => {
    return (
      <DeleteDeploymentModal
        handleClick={handleClick}
        deploymentIds={deploymentId}
      />
    )
  }

  const handleCheckID = (id: string) => {
    setAllSelect(false)
    if (deploymentId.find((deployment_id) => deployment_id === id)) {
      const value = deploymentId.filter((item) => item !== id)
      setDeploymentId(value)
    } else {
      setDeploymentId((prev) => [...prev, id])
    }
  }

  useEffect(() => {}, [deploymentId])

  return (
    <>
      <div className="flex justify-end mb-2">
        <div
          className="tooltip tooltip-primary"
          data-tip="Select the modules to delete"
        >
          <button
            className="btn btn-link btn-xs no-underline bg-base-200 hover:bg-base-300 flex gap-1 hover:no-underline"
            disabled={!deploymentId.length}
            onClick={() => setModal(true)}
          >
            <TrashIcon className="w-3 h-3" />
            {t("delete")}
          </button>
        </div>
      </div>
      <div className="overflow-x-auto bg-base-100 border border-base-300 p-0">
        <table className="w-full divide-y divide-base-200 border border-base-200 rounded-md">
          <thead className="bg-base-200">
            <tr>
              {headers.map((header) => (
                <th
                  key={header.label}
                  scope="col"
                  className="px-4 py-3 text-xs md:text-sm font-medium text-left text-base-content tracking-wider"
                >
                  <div className="relative">
                    <div className="absolute -left-4 top-1">
                      <ChevronUpIcon
                        className={classNames(
                          sortField === header.field &&
                            sortDirection === SORT_DIRECTION.ASC
                            ? "text-normal"
                            : "hidden",
                          "h-3",
                        )}
                      />
                      <ChevronDownIcon
                        className={classNames(
                          sortField === header.field &&
                            sortDirection === SORT_DIRECTION.DESC
                            ? "text-normal"
                            : "hidden",
                          "h-3",
                        )}
                      />
                    </div>
                    <div className="flex gap-1">
                      {header.label === "Module" && deploymentId.length > 0 && (
                        <span className="flex gap-2">
                          <input
                            type="checkbox"
                            //@ts-ignore
                            checked={
                              isAllSelect && deploymentId.length && "checked"
                            }
                            className="checkbox checkbox-xs checkbox-primary mt-1"
                            onChange={() =>
                              deployments &&
                              deployments.length &&
                              handleAllCheckBox(deployments, !isAllSelect)
                            }
                          />
                        </span>
                      )}
                      <div
                        className={classNames(
                          sortField === header.field
                            ? "text-normal font-semibold"
                            : "text-normal",
                          "cursor-pointer hover:text-normal transition",
                        )}
                        onClick={setSort(header)}
                      >
                        {header.label}
                      </div>
                    </div>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-base-100 divide-y-2 divide-base-200">
            {deployments
              ?.filter((item) => !item.hasOwnProperty("deletedAt"))
              ?.sort(tableSort)
              .map((deployment, index) => {
                const statusColor = textColorFromDeployStatus(deployment.status)

                let time: FirestoreTimestamp =
                  deployment.createdAt as FirestoreTimestamp
                const fireBaseTime = new Date(
                  time._seconds * 1000 + time._nanoseconds / 1000000,
                )
                const date = fireBaseTime.toLocaleDateString()

                return (
                  <tr
                    key={index}
                    className="border border-t-1 border-base-300 text-xs md:text-sm xl:text-base"
                  >
                    <td className="pl-4 py-3">
                      {deployment.status === DEPLOYMENT_STATUS.SUCCESS ? (
                        <span className="flex gap-2 text-sm font-semibold text-dim">
                          <input
                            type="checkbox"
                            //@ts-ignore
                            checked={
                              deploymentId.find(
                                (ID) => ID === deployment.deploymentId,
                              )
                                ? "checked"
                                : ""
                            }
                            className="checkbox checkbox-xs checkbox-primary mt-1"
                            onChange={() =>
                              handleCheckID(deployment.deploymentId)
                            }
                          />
                          {startCase(deployment.module)}
                        </span>
                      ) : (
                        <span className="flex gap-2 text-sm font-semibold text-dim">
                          {startCase(deployment.module)}
                        </span>
                      )}
                    </td>
                    <td className="pl-4 py-3">
                      <a
                        className="link link-primary link-hover"
                        onClick={handleDeployment(deployment)}
                        data-id={deployment.deploymentId}
                      >
                        {deployment.deploymentId}
                      </a>
                    </td>
                    <td className="pl-4 py-3 text-xs md:text-sm">
                      <ProjectLink deployment={deployment} />
                    </td>
                    <td className="pl-4 py-3 text-xs md:text-sm text-faint">
                      {deployment.deployedByEmail}
                    </td>
                    <td className="pl-4 py-3 text-xs md:text-sm text-faint">
                      {date}
                    </td>
                    <td className="pl-4 py-3 text-xs xl:text-sm pr-2 text-dim">
                      {deployment.deletedAt ? (
                        <span className="text-error text-dim font-semibold">
                          DELETED
                        </span>
                      ) : (
                        <span
                          className={`text-${statusColor} text-dim font-semibold`}
                        >
                          {deployment.status}
                        </span>
                      )}
                    </td>
                  </tr>
                )
              })}
          </tbody>
        </table>
        {isModal && renderModal()}
      </div>
    </>
  )
}

export default ModuleDeployment
