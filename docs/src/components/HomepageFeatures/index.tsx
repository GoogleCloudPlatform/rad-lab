import React from "react";
import clsx from "clsx";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  img: string;
  description: JSX.Element;
};

// type SvgFeatureItem = {
//   title: string;
//   Svg: React.ComponentType<React.ComponentProps<"svg">>;
//   description: JSX.Element;
// };

const FeatureList: FeatureItem[] = [
  {
    title: "Up and Running - Fast",
    img: "img/quick.png",
    // Svg: require("@site/static/img/great-design.svg").default,
    description: (
      <>
        RAD Lab features its own UI, which gives non-technical users an
        intuitive and easy-to-use experience.
      </>
    ),
  },
  {
    title: "Promote Collaboration",
    img: "img/collaboration.png",
    // Svg: require("@site/static/img/team-up.svg").default,
    description: (
      <>
        Admins create secure constraints for users then users can deploy the
        modules they need for their workloads in a self-service fashion.
      </>
    ),
  },
  {
    title: "Complete and Customizeable",
    img: "img/customize.png",
    // Svg: require("@site/static/img/configurable.svg").default,
    description: (
      <>
        We give you sane and secure defaults out of the box. RAD Lab is open
        source, so you are free to tweak every aspect to fit your needs.
      </>
    ),
  },
];

// function SVGFeature({ title, Svg, description }: FeatureItem) {
//   return (
//     <div className={clsx("col col--4")}>
//       <div className="text--center">
//         <Svg className={styles.featureSvg} role="img" />
//       </div>
//       <div className="text--center padding-horiz--md">
//         <h3>{title}</h3>
//         <p>{description}</p>
//       </div>
//     </div>
//   );
// }

function Feature({ title, img, description }: FeatureItem) {
  return (
    <div style={{ marginBottom: "4rem" }} className={clsx("col col--4")}>
      <div className="text--center">
        <img
          style={{ height: "12rem" }}
          className="img-fluid"
          src={img}
          alt={title}
        />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
