import axios from "axios"
import { useTranslation } from "next-i18next"
import { useState } from "react"
import { useNavigate } from "react-router-dom"
import { alertStore, userStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import Loading from "@/navigation/Loading"

interface IDeleteDeploymentModal {
  deployId: string
  handleClick: Function
}

const DeleteDeploymentModal: React.FC<IDeleteDeploymentModal> = ({
  deployId,
  handleClick,
}) => {
  const [modal, setModal] = useState(true)
  const navigate = useNavigate()
  const { t } = useTranslation()
  const setAlert = alertStore((state) => state.setAlert)
  const [loading, setLoading] = useState(false)
  const user = userStore((state) => state.user)

  const handleDelete = async () => {
    const config = {
      data: { deployedByEmail: user?.email },
    }

    setLoading(true)
    await axios
      .delete(`/api/deployments/${deployId}`, config)
      .then((res) => {
        if (res.status === 200) {
          setAlert({
            message: t("delete-success"),
            durationMs: 10000,
            type: ALERT_TYPE.SUCCESS,
          })
          navigate("/deployments")
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
          <h3 className="font-bold text-lg">{t("delete")}</h3>
          <p className="py-4">{t("delete-deployment")}</p>
          <p className="text-md font-normal">
            {`${t("deployment-id")} ${deployId}`}
          </p>
          <div className="modal-action">
            {loading ? (
              <Loading />
            ) : (
              <button className="btn btn-error" onClick={handleDelete}>
                {t("delete")}
              </button>
            )}
            <button
              className="btn btn-outline"
              onClick={() => {
                setModal(false), handleClick(false)
              }}
            >
              {t("close")}
            </button>
          </div>
        </div>
      </div>
    </>
  )
}

export default DeleteDeploymentModal
