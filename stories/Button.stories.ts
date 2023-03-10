import { Meta, StoryFn } from '@storybook/html';
import { withDesign } from 'storybook-addon-designs';
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
  decorators: [ withDesign ],
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
Default.parameters = {
  design: {
    type: 'figma',
    url: 'https://www.figma.com/file/6ezYLCsTndj2HCCrlYJuRR/BKUI?node-id=1518%3A252&t=gP3J9M0lpUMIBnzz-1',
  },
};

export const Primary = Template.bind({});
Primary.args = {
  ...Default.args,
  type: ButtonType.Primary,
};
Primary.parameters = {
  ...Default.parameters,
}

export const Purple = Template.bind({});
Purple.args = {
  ...Default.args,
  type: ButtonType.Purple,
};
Purple.parameters = {
  ...Default.parameters,
}

export const Link = Template.bind({});
Link.args = {
  ...Default.args,
  type: ButtonType.Link,
};
Link.parameters = {
  ...Default.parameters,
}
