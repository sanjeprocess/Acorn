import type { BoxProps, CardProps } from '@mui/material';

import {
  Box,
  Card,
  Avatar,
  Rating,
  CardHeader,
  Typography,
  CircularProgress,
  Stack,
  Divider,
  Chip,
} from '@mui/material';

import { Iconify } from 'src/components/iconify';
import { Scrollbar } from '../../components/scrollbar';

type Props = CardProps & {
  title?: string;
  subheader?: string;
  list: FeedbackProps[];
  isLoading: boolean;
};

export type FeedbackProps = {
  feedbackId: string;
  rating: string;
  feedback: string;
  createdAt?: string;
  customer: Customer;
  csa?: {
    csaId: number;
    name: string;
  };
  travel?: {
    startingLocation: string;
    destination: string;
    travelDate?: string;
  };
};

export type Customer = {
  name: string;
  csa: string | number;
  email: string;
};

export function FeedBackTable({ title, subheader, list, isLoading, ...other }: Props) {
  return (
    <Card {...other}>
      <CardHeader title={title} subheader={subheader} sx={{ mb: 1 }} />

      <Scrollbar sx={{ maxHeight: 600 }}>
        <Box sx={{ px: 2, py: 1 }}>
          {isLoading ? (
            <Box
              sx={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                height: 300,
              }}
            >
              <CircularProgress />
            </Box>
          ) : list?.length > 0 ? (
            list.map((post) => <PostItem key={post.feedbackId} item={post} />)
          ) : (
            <Box
              sx={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                height: 300,
              }}
            >
              <Typography variant="subtitle1" align="center" sx={{ py: 5, color: 'text.secondary' }}>
                No feedback data available
              </Typography>
            </Box>
          )}
        </Box>
      </Scrollbar>
    </Card>
  );
}

// ----------------------------------------------------------------------

function PostItem({ sx, item, ...other }: BoxProps & { item: Props['list'][number] }) {
  const formatDate = (dateString?: string) => {
    if (!dateString) return '';
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      });
    } catch {
      return dateString;
    }
  };

  return (
    <Card
      sx={{
        p: 3,
        mb: 3,
        borderRadius: 2,
        boxShadow: (theme) => theme.customShadows.card,
        border: (theme) => `1px solid ${theme.palette.divider}`,
        transition: 'all 0.3s ease',
        '&:hover': {
          boxShadow: (theme) => theme.customShadows.z24,
          transform: 'translateY(-2px)',
        },
        ...sx,
      }}
    >
      {/* Header Section */}
      <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
        <Avatar
          sx={{
            bgcolor: 'primary.main',
            width: 56,
            height: 56,
            fontSize: '1.5rem',
            fontWeight: 600,
          }}
        >
          {item.customer.name.charAt(0).toUpperCase()}
        </Avatar>

        <Box sx={{ flex: 1, minWidth: 0 }}>
          <Typography variant="h6" fontWeight={600} noWrap>
            {item.customer.name}
          </Typography>
          <Typography variant="body2" color="text.secondary" noWrap>
            {item.customer.email}
          </Typography>
        </Box>

        <Box sx={{ textAlign: 'right', flexShrink: 0 }}>
          <Rating readOnly value={Number(item.rating)} size="small" />
          {item.createdAt && (
            <Typography variant="caption" color="text.secondary" display="block" sx={{ mt: 0.5 }}>
              {formatDate(item.createdAt)}
            </Typography>
          )}
        </Box>
      </Box>

      <Divider sx={{ my: 2 }} />

      {/* Feedback Content */}
      <Box sx={{ mb: 2 }}>
        <Typography variant="body1" color="text.primary" sx={{ whiteSpace: 'pre-wrap' }}>
          {item.feedback}
        </Typography>
      </Box>

      {/* Trip Details */}
      {item.travel && (
        <Box
          sx={{
            p: 2,
            borderRadius: 1.5,
            bgcolor: 'background.neutral',
            mb: 2,
          }}
        >
          <Typography variant="caption" color="text.secondary" fontWeight={600} sx={{ mb: 1, display: 'block' }}>
            TRIP DETAILS
          </Typography>
          <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <Iconify icon="mdi:map-marker-outline" width={18} color="primary.main" />
              <Typography variant="body2" fontWeight={500}>
                {item.travel.startingLocation}
              </Typography>
            </Box>
            <Iconify icon="mdi:arrow-right" width={20} sx={{ color: 'text.secondary' }} />
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
              <Iconify icon="mdi:map-marker" width={18} color="error.main" />
              <Typography variant="body2" fontWeight={500}>
                {item.travel.destination}
              </Typography>
            </Box>
            {item.travel.travelDate && (
              <Box sx={{ ml: 'auto', display: 'flex', alignItems: 'center', gap: 0.5 }}>
                <Iconify icon="mdi:calendar" width={16} sx={{ color: 'text.secondary' }} />
                <Typography variant="caption" color="text.secondary">
                  {formatDate(item.travel.travelDate)}
                </Typography>
              </Box>
            )}
          </Stack>
        </Box>
      )}

      {/* CSA Information */}
      {item.csa && (
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            pt: 1,
            borderTop: (theme) => `1px solid ${theme.palette.divider}`,
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Iconify icon="mdi:account-tie" width={18} sx={{ color: 'text.secondary' }} />
            <Typography variant="caption" color="text.secondary">
              CSA:
            </Typography>
            <Typography variant="body2" fontWeight={500}>
              {item.csa.name}
            </Typography>
          </Box>
          <Typography variant="caption" color="text.secondary">
            Review ID: #{item.feedbackId}
          </Typography>
        </Box>
      )}
    </Card>
  );
}
