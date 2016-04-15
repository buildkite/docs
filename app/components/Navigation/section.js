import React from "react";
import { Link as RouterLink } from 'react-router';

class Section extends React.Component {
  static childContextTypes = {
    section: React.PropTypes.object.isRequired
  };

  getChildContext() {
    return {
      section: this
    };
  }

  isExpanded() {
    // This section is expanded if the start of the current URL begins with the
    // path defined for this section

    return window.location.pathname.indexOf(this.props.path) == 0;
  }

  render() {
    let links = [];
    let children = React.Children.toArray(this.props.children);
    let href = this.props.path + children[0].props.href;

    if(this.isExpanded()) {
      return (
        <section>
          <p className="Docs__nav__section-heading">{this.props.title}</p>
          <ul className="Docs__nav__sub-nav">{children}</ul>
        </section>
      );
    } else {
      return (
        <section>
          <p className="Docs__nav__section-heading Docs__nav__section-heading--link">
            <RouterLink to={href} className="Link Link--on-white Link--underline Docs__nav__section-heading-link">
              {this.props.title}
            </RouterLink>
          </p>
        </section>
      );
    }
  }
}

export default Section;
