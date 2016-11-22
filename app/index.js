import React from 'react';
import ReactDOM from 'react-dom';
import Routes from './routes';

// Toggle on development features
if (process.env.NODE_ENV !== "production") {
  require('react-type-snob').default(React);
}

ReactDOM.render(Routes, document.getElementById('root'));
