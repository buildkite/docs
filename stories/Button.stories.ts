import { Meta, StoryFn } from '@storybook/html';
import cn from 'classnames';

enum ButtonType {
  Default = 'Default',
  Primary = 'Primary',
  Purple = 'Purple',
  Link = 'Link',
}

type ButtonArgs = {
  type: ButtonType;
  label: string;
  small: string;
  dropdown: boolean;
}

export default { 
  title: 'Components/Button',
  argTypes: {
    type: {
      control: {
        type: 'radio',
        options: [
          ButtonType.Default,
          ButtonType.Primary,
          ButtonType.Purple,
          ButtonType.Link,
        ]
      },
    },
  },
} as Meta<ButtonArgs>;

const Template: StoryFn<ButtonArgs> = (args): HTMLButtonElement => {
  const Button = document.createElement('button');
  Button.innerText = args.label;
  Button.className = cn(
    'Button',
    args.type === ButtonType.Default && 'Button--default',
    args.type === ButtonType.Primary && 'Button--primary',
    args.type === ButtonType.Purple && 'Button--purple',
    args.type === ButtonType.Link && 'Button--link',
    args.small && 'Button--small',
    args.dropdown && 'Button--dropdown'
  );

  return Button;
}

export const Default = Template.bind({});
Default.args = {
  type: ButtonType.Default,
  label: 'Button',
  small: false,
  dropdown: false,
};

export const Primary = Template.bind({});
Primary.args = {
  ...Default.args,
  type: ButtonType.Primary,
};

export const Purple = Template.bind({});
Purple.args = {
  ...Default.args,
  type: ButtonType.Purple,
};

export const Link = Template.bind({});
Link.args = {
  ...Default.args,
  type: ButtonType.Link,
};
