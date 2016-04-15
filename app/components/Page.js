import React from "react";

class Page extends React.Component {
  render() {
    let path = this.props.path || "/";

    return (
      <div>
        This is a a page {path}
      </div>
    );
  }
}

export default Page;
