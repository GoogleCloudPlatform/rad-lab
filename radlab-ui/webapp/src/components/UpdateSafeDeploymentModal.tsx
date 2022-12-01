import axios from "axios"
import { useTranslation } from "next-i18next"
import { useState } from "react"
import { useNavigate } from "react-router-dom"
import { alertStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import Loading from "@/navigation/Loading"
import startCase from "lodash/startCase"

interface IFormatData {
  [key: string]: any
}
interface IUpdateSafeDeploymentModal {
  deployId: string
  safeUpdatePayload: IFormatData
  safeUpdateData: IFormatData
}

const UpdateSafeDeploymentModal: React.FC<IUpdateSafeDeploymentModal> = ({
  deployId,
  safeUpdatePayload,
  safeUpdateData,
}) => {
  const [modal, setModal] = useState(true)
  const navigate = useNavigate()
  const { t } = useTranslation()
  const setAlert = alertStore((state) => state.setAlert)
  const [loading, setLoading] = useState(false)

  const handleCloseUpdateSafe = () => {
    setModal(false)
    navigate(`/deployments/${deployId}`)
  }
  const handleUpdateSafe = async () => {
    setLoading(true)
    await axios
      .put(`/api/deployments/${deployId}`, safeUpdatePayload)
      .then((res) => {
        if (res.status === 200) {
          setAlert({
            message: t("update-success"),
            durationMs: 10000,
            type: ALERT_TYPE.SUCCESS,
          })
          navigate("/deployments")
        } else {
          setAlert({
            message: t("update-error"),
            durationMs: 10000,
            type: ALERT_TYPE.ERROR,
          })
          setModal(false)
        }
      })
      .catch((error) => {
        setAlert({
          message: t("update-error"),
          durationMs: 10000,
          type: ALERT_TYPE.ERROR,
        })
        console.error(error)
        setModal(false)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  return (
    <>
      <input
        type="checkbox"
        id="my-modal"
        className="modal-toggle"
        readOnly
        checked={modal}
      />
      <div className="modal">
        <div className="modal-box">
          <h3 className="font-bold text-lg">{t("update")}</h3>
          <p className="py-4">{t("unsafe-deployment")}</p>
          <p className="text-md font-normal">
            {`${t("deployment-id")} ${deployId}`}
          </p>
          <p className="text-md font-normal">
            {Object.keys(safeUpdateData).map((fieldVariable) => {
              return (
                <span
                  key={fieldVariable}
                  className="badge badge-primary badge-outline mr-2"
                >
                  {startCase(fieldVariable)}
                </span>
              )
            })}
          </p>
          <div className="modal-action">
            {loading ? (
              <Loading />
            ) : (
              <button className="btn btn-error" onClick={handleUpdateSafe}>
                {t("update")}
              </button>
            )}
            <button className="btn btn-outline" onClick={handleCloseUpdateSafe}>
              {t("close")}
            </button>
          </div>
        </div>
      </div>
    </>
  )
}

export default UpdateSafeDeploymentModal
