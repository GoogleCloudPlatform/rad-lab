interface GlobalAlertProps {}
import { alertStore } from "@/store"
import { classNames } from "@/utils/dom"
import { ALERT_TYPE } from "@/utils/types"
import {
  ExclamationIcon,
  ExclamationCircleIcon,
  ThumbUpIcon,
  XIcon,
  InformationCircleIcon,
} from "@heroicons/react/outline"

const GlobalAlert: React.FC<GlobalAlertProps> = () => {
  const alert = alertStore((state) => state.alert)
  const setAlert = alertStore((state) => state.setAlert)

  if (!alert) return <></>
  if (alert.closeable === false && !alert.durationMs) {
    console.warn("Alert will always stay open")
  }

  const alertType =
    alert.type === ALERT_TYPE.SUCCESS
      ? "success"
      : alert.type === ALERT_TYPE.WARNING
      ? "warning"
      : alert.type === ALERT_TYPE.ERROR
      ? "error"
      : "info"

  const IconComponent =
    alertType === "success"
      ? ThumbUpIcon
      : alertType === "error"
      ? ExclamationCircleIcon
      : alertType === "warning"
      ? ExclamationIcon
      : InformationCircleIcon

  return (
    <div
      data-testid="global-alert"
      className={classNames(
        "alert p-3 shadow-lg w-full bg-opacity-75",
        `alert-${alertType}`,
      )}
    >
      {/* Hidden span to ensure all potentially used classes are not purged */}
      <span className="hidden text-error-content text-warning-content text-success-content text-info-content alert-error alert-warning alert-success alert-info"></span>

      <div className="flex justify-between items-center">
        <div className="flex flex-row items-center mr-2">
          <IconComponent className="w-6 mr-3 shrink-0" />
          <div data-testid="global-alert-message">{alert.message}</div>
        </div>

        <div
          data-testid="global-alert-close"
          onClick={() => setAlert(null)}
          className={classNames(
            "group bg-base-100 rounded-md cursor-pointer bg-opacity-0 hover:bg-opacity-20 transition",
            alert.closeable === false ? "hidden" : "",
          )}
        >
          <XIcon
            className={classNames(
              "w-6 m-1 shrink-0 opacity-75 group-hover:opacity-100 transition",
              `text-${alertType}-content`,
            )}
          />
        </div>
      </div>
    </div>
  )
}

export default GlobalAlert
