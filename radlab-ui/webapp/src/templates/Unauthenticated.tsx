import { ReactNode, useEffect } from "react"

type IUnauthenticatedProps = {
  meta: ReactNode
  children: ReactNode
}

const Unauthenticated = (props: IUnauthenticatedProps) => {
  // NextJS doesn't allow editing this field with className
  useEffect(() => {
    document.querySelector("#__next")?.classList.add("h-full")
  })

  return (
    <div className="h-full w-full text-base-content">
      {props.meta}

      <div className="w-full mx-auto min-h-full">{props.children}</div>
    </div>
  )
}
export default Unauthenticated
