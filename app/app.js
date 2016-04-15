import React from "react";
import ReactDOM from 'react-dom';
import { Router, Route, Redirect, browserHistory } from "react-router";

import Main from "./components/Main";

ReactDOM.render(
  <Router history={browserHistory}>
    <Redirect from="/docs" to="/docs/guides/getting-started" />
    <Route path="/docs">
      <Route path="*" component={Main} />
    </Route>
  </Router>
, document.getElementById('root'));
