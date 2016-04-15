import React from "react";

class Page extends React.Component {
  render() {
    let path = this.props.path;
    path.replace(/\-/, "_");

    let contents = require("../../pages/" + path + ".md");

    return (
      <section dangerouslySetInnerHTML={{ __html: contents }} />
    );
  }
}

export default Page;
