import { SvgColor } from 'src/components/svg-color';


// ----------------------------------------------------------------------

const icon = (name: string) => (
  <SvgColor width="100%" height="100%" src={`/assets/icons/navbar/${name}.svg`} />
);

export const navData = [
  {
    title: 'User',
    path: '/secured/user',
    icon: icon('ic-user'),
  },
//   {
//     title: 'Product',
//     path: '/products',
//     icon: icon('ic-cart'),
//   },
  {
    title: 'Feedback',
    path: '/secured/feedback',
    icon: icon('ic-analytics'),
  },
  {
    title: 'Incidents',
    path: '/secured/incidents',
    icon: icon('ic-lock'),
  }
//   {
//     title: 'Blog',
//     path: '/blog',
//     icon: icon('ic-lock'),
//   },
//   {
//     title: 'Sign in',
//     path: '/sign-in',
//     icon: icon('ic-lock'),
//   },
//   {
//     title: 'Not found',
//     path: '/404',
//     icon: icon('ic-disabled'),
//   },
];
