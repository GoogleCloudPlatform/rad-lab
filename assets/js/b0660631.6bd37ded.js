"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9703],{3632:(e,i,n)=>{n.r(i),n.d(i,{assets:()=>r,contentTitle:()=>o,default:()=>c,frontMatter:()=>a,metadata:()=>t,toc:()=>d});var l=n(4848),s=n(8453);const a={sidebar_position:5,title:"05 - Publishing Modules"},o="Publishing Modules",t={id:"rad-lab-ui/ui_installation/publishing-modules",title:"05 - Publishing Modules",description:"No modules will be available for Users to deploy until an Admin publishes them.",source:"@site/docs/rad-lab-ui/ui_installation/publishing-modules.md",sourceDirName:"rad-lab-ui/ui_installation",slug:"/rad-lab-ui/ui_installation/publishing-modules",permalink:"/rad-lab/docs/rad-lab-ui/ui_installation/publishing-modules",draft:!1,unlisted:!1,tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5,title:"05 - Publishing Modules"},sidebar:"tutorialSidebar",previous:{title:"04 - Web Application",permalink:"/rad-lab/docs/rad-lab-ui/ui_installation/frontend"},next:{title:"06 - Cleanup Environment",permalink:"/rad-lab/docs/rad-lab-ui/ui_installation/cleanup"}},r={},d=[{value:"Global Admin Variables",id:"global-admin-variables",level:2},{value:"Email Notifications",id:"email-notifications",level:4},{value:"Module Admin Variables",id:"module-admin-variables",level:2}];function u(e){const i={a:"a",admonition:"admonition",code:"code",h1:"h1",h2:"h2",h4:"h4",li:"li",p:"p",ul:"ul",...(0,s.R)(),...e.components};return(0,l.jsxs)(l.Fragment,{children:[(0,l.jsx)(i.h1,{id:"publishing-modules",children:"Publishing Modules"}),"\n",(0,l.jsx)(i.admonition,{title:"Important",type:"danger",children:(0,l.jsx)(i.p,{children:"No modules will be available for Users to deploy until an Admin publishes them."})}),"\n",(0,l.jsx)(i.h2,{id:"global-admin-variables",children:"Global Admin Variables"}),"\n",(0,l.jsx)(i.p,{children:"Some variables are common to all modules. Upon first log in, and Admin will set these variables, so that users will not need to add them. These include (but not limited to):"}),"\n",(0,l.jsxs)(i.ul,{children:["\n",(0,l.jsx)(i.li,{children:"Billing ID"}),"\n",(0,l.jsxs)(i.li,{children:["Organization ID (without ",(0,l.jsx)(i.code,{children:"organizations/"}),"-prefix)"]}),"\n",(0,l.jsxs)(i.li,{children:["Folder ID (without ",(0,l.jsx)(i.code,{children:"folders/"}),"-prefix)"]}),"\n",(0,l.jsx)(i.li,{children:"Email Notification(enable/disable email notifications)"}),"\n"]}),"\n",(0,l.jsx)(i.h4,{id:"email-notifications",children:"Email Notifications"}),"\n",(0,l.jsx)(i.p,{children:"You can optionally enable RAD Lab notification for deployment events. This includes deployment creations, updates, and deletions."}),"\n",(0,l.jsx)(i.p,{children:"If enabled, the following users/groups (defined in the module's Terraform variables) will receive email notifications:"}),"\n",(0,l.jsxs)(i.ul,{children:["\n",(0,l.jsx)(i.li,{children:"The individual taking the action"}),"\n",(0,l.jsx)(i.li,{children:(0,l.jsx)(i.code,{children:"trusted_users"})}),"\n",(0,l.jsx)(i.li,{children:(0,l.jsx)(i.code,{children:"trusted_groups"})}),"\n",(0,l.jsx)(i.li,{children:(0,l.jsx)(i.code,{children:"owner_users"})}),"\n",(0,l.jsx)(i.li,{children:(0,l.jsx)(i.code,{children:"owner_groups"})}),"\n"]}),"\n",(0,l.jsxs)(i.p,{children:["Currently only sending via gmail is supported. It is recommended to ",(0,l.jsx)(i.a,{href:"https://support.google.com/mail/answer/56256?hl=en",children:"create a new gmail address"})," for this purpose only and generate an ",(0,l.jsx)(i.code,{children:"App Password"})," to authenticate it by following ",(0,l.jsx)(i.a,{href:"https://support.google.com/mail/answer/185833?hl=en",children:"these directions"}),"."]}),"\n",(0,l.jsxs)(i.p,{children:["You will then provide this email and its password to RAD Lab UI via the ",(0,l.jsx)(i.code,{children:"Global Variables"})," setup."]}),"\n",(0,l.jsxs)(i.p,{children:["The email address will be store in Firestore, and email password will be securely stored in Google's ",(0,l.jsx)(i.a,{href:"https://cloud.google.com/secret-manager",children:"Secret Manager"})]}),"\n",(0,l.jsx)(i.h2,{id:"module-admin-variables",children:"Module Admin Variables"}),"\n",(0,l.jsx)(i.p,{children:"Lastly, some modules have specific requirements for variables that typical Users may not know, understand how to obtain, or even be authorized to access."}),"\n",(0,l.jsx)(i.p,{children:"Once an Admin tries to publish a module, if the module requires any of these variables, the Admin will be prompted. These values will be saved in Firestore and inaccessible to Users."}),"\n",(0,l.jsx)(i.p,{children:"When a User deploys a module, Global and Module Admin Variables will be combined with the variables the User provided and passed to Terraform for execution (User variables supersede all other variables of the same name, and Module Admin variable supersede Global Admin variables of the same name)."})]})}function c(e={}){const{wrapper:i}={...(0,s.R)(),...e.components};return i?(0,l.jsx)(i,{...e,children:(0,l.jsx)(u,{...e})}):u(e)}},8453:(e,i,n)=>{n.d(i,{R:()=>o,x:()=>t});var l=n(6540);const s={},a=l.createContext(s);function o(e){const i=l.useContext(a);return l.useMemo((function(){return"function"==typeof e?e(i):{...i,...e}}),[i,e])}function t(e){let i;return i=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:o(e.components),l.createElement(a.Provider,{value:i},e.children)}}}]);