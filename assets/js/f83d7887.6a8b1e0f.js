"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[17],{3905:(e,t,r)=>{r.d(t,{Zo:()=>c,kt:()=>m});var a=r(7294);function n(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function o(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,a)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?o(Object(r),!0).forEach((function(t){n(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):o(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function l(e,t){if(null==e)return{};var r,a,n=function(e,t){if(null==e)return{};var r,a,n={},o=Object.keys(e);for(a=0;a<o.length;a++)r=o[a],t.indexOf(r)>=0||(n[r]=e[r]);return n}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(a=0;a<o.length;a++)r=o[a],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(n[r]=e[r])}return n}var u=a.createContext({}),s=function(e){var t=a.useContext(u),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},c=function(e){var t=s(e.components);return a.createElement(u.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},p=a.forwardRef((function(e,t){var r=e.components,n=e.mdxType,o=e.originalType,u=e.parentName,c=l(e,["components","mdxType","originalType","parentName"]),p=s(r),m=n,f=p["".concat(u,".").concat(m)]||p[m]||d[m]||o;return r?a.createElement(f,i(i({ref:t},c),{},{components:r})):a.createElement(f,i({ref:t},c))}));function m(e,t){var r=arguments,n=t&&t.mdxType;if("string"==typeof e||n){var o=r.length,i=new Array(o);i[0]=p;var l={};for(var u in t)hasOwnProperty.call(t,u)&&(l[u]=t[u]);l.originalType=e,l.mdxType="string"==typeof e?e:n,i[1]=l;for(var s=2;s<o;s++)i[s]=r[s];return a.createElement.apply(null,i)}return a.createElement.apply(null,r)}p.displayName="MDXCreateElement"},7662:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>u,contentTitle:()=>i,default:()=>d,frontMatter:()=>o,metadata:()=>l,toc:()=>s});var a=r(7462),n=(r(7294),r(3905));const o={sidebar_position:1},i="Customizing Modules",l={unversionedId:"rad-lab-launcher/launcher_configure/customizing-modules",id:"rad-lab-launcher/launcher_configure/customizing-modules",title:"Customizing Modules",description:"After you have cloned the the official RAD Lab repository, you can customize every module's defaults to match your organization's needs.",source:"@site/docs/rad-lab-launcher/launcher_configure/customizing-modules.md",sourceDirName:"rad-lab-launcher/launcher_configure",slug:"/rad-lab-launcher/launcher_configure/customizing-modules",permalink:"/rad-lab/docs/rad-lab-launcher/launcher_configure/customizing-modules",draft:!1,tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"tutorialSidebar",previous:{title:"Configure Modules",permalink:"/rad-lab/docs/launcher_configure"},next:{title:"Module Deployment",permalink:"/rad-lab/docs/launcher_deployment"}},u={},s=[{value:"Overriding default variables of a RAD Lab Module",id:"overriding-default-variables-of-a-rad-lab-module",level:2}],c={toc:s};function d(e){let{components:t,...r}=e;return(0,n.kt)("wrapper",(0,a.Z)({},c,r,{components:t,mdxType:"MDXLayout"}),(0,n.kt)("h1",{id:"customizing-modules"},"Customizing Modules"),(0,n.kt)("p",null,"After you have ",(0,n.kt)("a",{parentName:"p",href:"../../launcher_installation/source-control"},"cloned the the official RAD Lab repository"),", you can customize every module's defaults to match your organization's needs."),(0,n.kt)("h2",{id:"overriding-default-variables-of-a-rad-lab-module"},"Overriding default variables of a RAD Lab Module"),(0,n.kt)("p",null,"To set any module specific variables, use ",(0,n.kt)("inlineCode",{parentName:"p"},"--varfile")," argument while running ",(0,n.kt)("a",{parentName:"p",href:"/rad-lab/docs/rad-lab-launcher/launcher_deployment/launcher"},"RAD Lab Launcher")," (",(0,n.kt)("strong",{parentName:"p"},"radlab.py"),") and pass a file with variables content. Variables like ",(0,n.kt)("strong",{parentName:"p"},"organization_id"),", ",(0,n.kt)("strong",{parentName:"p"},"folder_id"),", ",(0,n.kt)("strong",{parentName:"p"},"billing_account_id"),", ",(0,n.kt)("strong",{parentName:"p"},"random_id")," (a.k.a. ",(0,n.kt)("strong",{parentName:"p"},"deployment id"),"), which are requested as part of guided setup, can be set via ",(0,n.kt)("inlineCode",{parentName:"p"},"--varfile")," argument by passing them in a file. "),(0,n.kt)("p",null,"Based on the ",(0,n.kt)("a",{parentName:"p",href:"https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules"},"module")," which you are deploying, review the ",(0,n.kt)("inlineCode",{parentName:"p"},"variables.tf")," file to determine the type of variable, and accordingly, set the variable values in the file to override the default variables."),(0,n.kt)("p",null,(0,n.kt)("em",{parentName:"p"},"Usage :")),(0,n.kt)("pre",null,(0,n.kt)("code",{parentName:"pre",className:"language-bash"},"python3 radlab.py --varfile /<path_to_file>/<file_with_terraform.tfvars_contents>\n")),(0,n.kt)("p",null,(0,n.kt)("strong",{parentName:"p"},"NOTE:")," When the above argument is not passed then the modules are deployed with module's default variable values in the ",(0,n.kt)("inlineCode",{parentName:"p"},"variables.tf")," file."))}d.isMDXComponent=!0}}]);