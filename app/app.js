import React from "react";
import ReactDOM from 'react-dom';
import { Route, IndexRoute, browserHistory } from "react-router";

class Page extends React.Component {
  render() {
    return (
      <div>
        This is a a page
      </div>
    );
  }
}

ReactDOM.render(
  <RelayRouter history={browserHistory}>
    <Route path="/" component={Page} />
  </RelayRouter>
, document.getElementById('root'));
