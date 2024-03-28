"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2462],{531:(e,n,r)=>{r.r(n),r.d(n,{assets:()=>s,contentTitle:()=>t,default:()=>u,frontMatter:()=>i,metadata:()=>l,toc:()=>d});var a=r(4848),o=r(8453);const i={sidebar_position:1},t="Customizing Modules",l={id:"rad-lab-launcher/launcher_configure/customizing-modules",title:"Customizing Modules",description:"After you have cloned the the official RAD Lab repository, you can customize every module's defaults to match your organization's needs.",source:"@site/docs/rad-lab-launcher/launcher_configure/customizing-modules.md",sourceDirName:"rad-lab-launcher/launcher_configure",slug:"/rad-lab-launcher/launcher_configure/customizing-modules",permalink:"/rad-lab/docs/rad-lab-launcher/launcher_configure/customizing-modules",draft:!1,unlisted:!1,tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"tutorialSidebar",previous:{title:"Configure Modules",permalink:"/rad-lab/docs/launcher_configure"},next:{title:"Module Deployment",permalink:"/rad-lab/docs/launcher_deployment"}},s={},d=[{value:"Overriding default variables of a RAD Lab Module",id:"overriding-default-variables-of-a-rad-lab-module",level:2}];function c(e){const n={a:"a",code:"code",em:"em",h1:"h1",h2:"h2",p:"p",pre:"pre",strong:"strong",...(0,o.R)(),...e.components};return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(n.h1,{id:"customizing-modules",children:"Customizing Modules"}),"\n",(0,a.jsxs)(n.p,{children:["After you have ",(0,a.jsx)(n.a,{href:"../../launcher_installation/source-control",children:"cloned the the official RAD Lab repository"}),", you can customize every module's defaults to match your organization's needs."]}),"\n",(0,a.jsx)(n.h2,{id:"overriding-default-variables-of-a-rad-lab-module",children:"Overriding default variables of a RAD Lab Module"}),"\n",(0,a.jsxs)(n.p,{children:["To set any module specific variables, use ",(0,a.jsx)(n.code,{children:"--varfile"})," argument while running ",(0,a.jsx)(n.a,{href:"/rad-lab/docs/rad-lab-launcher/launcher_deployment/launcher",children:"RAD Lab Launcher"})," (",(0,a.jsx)(n.strong,{children:"radlab.py"}),") and pass a file with variables content. Variables like ",(0,a.jsx)(n.strong,{children:"organization_id"}),", ",(0,a.jsx)(n.strong,{children:"folder_id"}),", ",(0,a.jsx)(n.strong,{children:"billing_account_id"}),", ",(0,a.jsx)(n.strong,{children:"random_id"})," (a.k.a. ",(0,a.jsx)(n.strong,{children:"deployment id"}),"), which are requested as part of guided setup, can be set via ",(0,a.jsx)(n.code,{children:"--varfile"})," argument by passing them in a file."]}),"\n",(0,a.jsxs)(n.p,{children:["Based on the ",(0,a.jsx)(n.a,{href:"https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules",children:"module"})," which you are deploying, review the ",(0,a.jsx)(n.code,{children:"variables.tf"})," file to determine the type of variable, and accordingly, set the variable values in the file to override the default variables."]}),"\n",(0,a.jsx)(n.p,{children:(0,a.jsx)(n.em,{children:"Usage :"})}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-bash",children:"python3 radlab.py --varfile /<path_to_file>/<file_with_terraform.tfvars_contents>\n"})}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.strong,{children:"NOTE:"})," When the above argument is not passed then the modules are deployed with module's default variable values in the ",(0,a.jsx)(n.code,{children:"variables.tf"})," file."]})]})}function u(e={}){const{wrapper:n}={...(0,o.R)(),...e.components};return n?(0,a.jsx)(n,{...e,children:(0,a.jsx)(c,{...e})}):c(e)}},8453:(e,n,r)=>{r.d(n,{R:()=>t,x:()=>l});var a=r(6540);const o={},i=a.createContext(o);function t(e){const n=a.useContext(i);return a.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(o):e.components||o:t(e.components),a.createElement(i.Provider,{value:n},e.children)}}}]);