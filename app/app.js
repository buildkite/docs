import React from "react";
import ReactDOM from 'react-dom';
import { Router, Route, Redirect, browserHistory } from "react-router";

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
    <Route path="/docs">
      <Redirect from="/" to="guides/getting-started" />
      <Route path="*" component={Main} />
    </Route>
  </Router>
, document.getElementById('root'));
