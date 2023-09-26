import axios from "axios"
import { useTranslation } from "next-i18next"
import { useState } from "react"
import { alertStore, userStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import Loading from "@/navigation/Loading"
import { XCircleIcon } from "@heroicons/react/outline"

interface IDeleteDeploymentModal {
  deployId?: string
  deploymentIds?: string[]
  handleClick: Function
  handleRefresh?: Function
}

const DeleteDeploymentModal: React.FC<IDeleteDeploymentModal> = ({
  deployId,
  deploymentIds,
  handleClick,
  handleRefresh,
}) => {
  const [modal, setModal] = useState(true)
  const { t } = useTranslation()
  const setAlert = alertStore((state) => state.setAlert)
  const [loading, setLoading] = useState(false)
  const user = userStore((state) => state.user)

  const handleDelete = async () => {
    const config1 = {
      data: { deployedByEmail: user?.email, deploymentIds: deploymentIds },
    }

    const config2 = {
      data: { deployedByEmail: user?.email },
    }

    setLoading(true)

    const request = deploymentIds?.length
      ? axios.delete(`/api/deployments`, config1)
      : axios.delete(`/api/deployments/${deployId}`, config2)

    request
      .then((res) => {
        if (res.status === 200) {
          setAlert({
            message: t("delete-success"),
            durationMs: 10000,
            type: ALERT_TYPE.SUCCESS,
          })
          handleRefresh && handleRefresh(true)
        } else {
          setAlert({
            message: t("delete-error"),
            durationMs: 10000,
            type: ALERT_TYPE.ERROR,
          })
          setModal(false)
        }
      })
      .catch((error) => {
        setAlert({
          message: t("delete-error"),
          durationMs: 10000,
          type: ALERT_TYPE.ERROR,
        })
        console.error(error)
        setModal(false)
      })
      .finally(() => {
        setLoading(false)
        setModal(false)
        handleClick(false)
      })
  }

  return (
    <>
      <input
        type="checkbox"
        id="my-modal"
        className="modal-toggle"
        checked={modal}
        readOnly
      />
      <div className="modal">
        <div className="modal-box">
          <div className="flex justify-center">
            <XCircleIcon className="w-12 h-12 text-error" />
          </div>
          <h3 className="font-bold text-lg text-center">
            {t("delete-deployment-title")}
            {"?"}
          </h3>
          <hr className="border border-base-200 mt-2" />
          <p className="p-1 bg-error bg-opacity-10 text-sm rounded-md mt-4 text-center text-error font-semibold">
            {t("delete-deployment-message")}
          </p>
          <div className="flex justify-center mt-2">
            {loading && <Loading />}
          </div>
          {deploymentIds?.length ? (
            <>
              {deploymentIds.map((deploymentId) => {
                return (
                  <p
                    className="text-sm font-normal mt-6 text-center font-semibold"
                    key={deploymentId}
                  >
                    {`${t("deployment-id")} ${deploymentId}`}
                  </p>
                )
              })}
            </>
          ) : (
            <p className="text-sm font-normal mt-6 text-center font-semibold">
              {`${t("deployment-id")} ${deployId}`}
            </p>
          )}
          <div className="modal-action">
            <button
              className="btn btn-outline btn-sm"
              onClick={() => {
                setModal(false), handleClick(false)
              }}
            >
              {t("close")}
            </button>
            <button
              className="btn btn-error btn-sm"
              onClick={() => {
                handleDelete()
              }}
            >
              {t("delete")}
            </button>
          </div>
        </div>
      </div>
    </>
  )
}

export default DeleteDeploymentModal
