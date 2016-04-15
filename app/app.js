import React from "react";
import ReactDOM from 'react-dom';
import { Router, Route, IndexRoute, browserHistory } from "react-router";

import Page from "./components/Page"

class Main extends React.Component {
  render() {
    return (
      <Page path={this.props.params.splat} />
    );
  }
}

ReactDOM.render(
  <Router history={browserHistory}>
    <Route path="*" component={Main} />
  </Router>
, document.getElementById('root'));
