import React from "react";

import Navigation from "./Navigation";
import Page from "./Page";

class Main extends React.Component {
  render() {
    return (
      <div>
        <div className="StandardTopSection--empty"></div>

        <div className="Docs__page-container StandardWhiteContentPage">
          <div className="Docs__page-container__inner PageContainer">
            <Navigation path={this.props.params.splat} />
            <Page path={this.props.params.splat} />
          </div>
        </div>
      </div>
    );
  }
}

export default Main;
