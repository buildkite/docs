import React from "react";
import classNames from "classnames";
import { Link as RouterLink } from 'react-router';

class Link extends React.Component {
  static contextTypes = {
    section: React.PropTypes.object.isRequired
  };

  render() {
    let listClassName = classNames({
      "Docs__nav__sub-nav__item": !this.props.indent,
      "Docs__nav__sub-nav__item--sub": this.props.indent
    });

    let href;
    if(this.props.href == "/") {
      href = this.context.section.props.path;
    } else {
      href = this.context.section.props.path + "/" + this.props.href;
    }

    return (
      <li className={listClassName}>
        <RouterLink to={href} className="Docs__nav__sub-nav__item__link Link--on-white Link--no-underline" activeClassName="active">
          {this.props.children}
        </RouterLink>
      </li>
    )
  }
}

export default Link;
