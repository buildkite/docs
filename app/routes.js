import React from 'react';
import { Router, Route, IndexRoute, browserHistory, applyRouterMiddleware } from 'react-router';
import { basename, dirname, extname } from 'path';
import DocumentTitle from 'react-document-title';

const baseTitle = "Buildkite Docs";

import NotFound from './not-found.mdx';

const GuideRequire = require.context(
  './pages',
  true,
  /\/[^\/]+(?:\/index)?\.[^\/]*$/ // matches any file in .pages, or any index file in a subdirectory of .pages
);

const resolvedRoutes = GuideRequire.keys().map((requirePath) => {
  const routePath = dirname(requirePath).slice(2); // remove './' from the start
  const guideExt = extname(requirePath);
  const guideName = basename(requirePath, guideExt);

  let path = `/${routePath}`;

  if (guideName !== 'index') {
    path = `${path}/${guideName}`;
  }

  return {
    requirePath,
    path
  }
});

// We're really only building the structure above so we can console.table these for debugging purposes
console.table(resolvedRoutes.map(({path, requirePath}) => ({path, resolved: requirePath})));

const routes = resolvedRoutes.map(({path, requirePath}) =>
  <Route key={path} path={path} component={GuideRequire(requirePath).default} />
);

routes.push(<Route key="/404" path="*" component={NotFound} />);

const documentTitleWrapper = (Component, props) => {
  const component = <Component {...props} />;

  if (Component.title) {
    return (
      <DocumentTitle title={`${Component.title} · ${baseTitle}`}>
        {component}
      </DocumentTitle>
    );
  }

  return component;
};

export default (
  <DocumentTitle title={baseTitle}>
    <Router createElement={documentTitleWrapper} history={browserHistory}>
      {routes}
    </Router>
  </DocumentTitle>
);