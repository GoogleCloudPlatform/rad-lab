import { useState } from "react"
import {
  CloudUploadIcon,
  CheckCircleIcon,
  ExclamationCircleIcon,
} from "@heroicons/react/outline"
import { classNames } from "@/utils/dom"
import Loading from "@/navigation/Loading"

const defaultAccept = "image/*,.pdf"

const DocumentUpload = ({
  type,
  label,
  handleFiles,
  accept,
  multiple,
}: {
  type: string
  label: string
  handleFiles: Function
  accept?: string
  multiple?: boolean
}) => {
  const [uploading, setUploading] = useState(false)
  const [uploaded, setUploaded] = useState(false)
  const [failed, setFailed] = useState(false)
  const [filesLabel, setFilesLabel] = useState<string | null>(null)
  multiple = multiple ?? false

  const onChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (!files) return
    setFailed(false)
    setUploaded(false)
    setUploading(true)

    try {
      await handleFiles({ files, type, label })
      setUploaded(true)
      setFilesLabel(
        files.length > 1
          ? `${files.length} files added`
          : files[0]?.name ?? "File added",
      )
    } catch (error) {
      setFailed(true)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="group flex items-center justify-center w-full">
      <label
        htmlFor={type}
        className={classNames(
          "flex flex-col w-full h-32 cursor-pointer border-4 border-dashed rounded-md transition",
          failed
            ? "border-error"
            : uploaded
            ? "border-success"
            : "border-base-300 text-faint group-hover:text-normal",
        )}
      >
        <div className="flex flex-col items-center justify-center pt-7">
          {failed ? (
            <ExclamationCircleIcon className="h-10 text-error transition" />
          ) : uploaded ? (
            <CheckCircleIcon className="h-10 text-success transition" />
          ) : uploading ? (
            <Loading />
          ) : (
            <CloudUploadIcon className="h-10 text-neutral" />
          )}
          <p
            className={classNames(
              failed
                ? "text-error"
                : uploaded
                ? "text-success"
                : "text-base-content",
              "pt-1 text-lg font-semibold",
            )}
          >
            {filesLabel || label}
          </p>
        </div>
        <input
          id={type}
          type="file"
          name={type}
          className="opacity-0 cursor-pointer w-full"
          accept={accept || defaultAccept}
          onChange={onChange}
          multiple={multiple}
          disabled={uploading}
        />
      </label>
    </div>
  )
}

export default DocumentUpload
