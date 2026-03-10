/* eslint-disable react/prop-types */
import { format } from 'date-fns';
import { memo, useMemo, useCallback } from 'react';

import { Box, Card, Chip, Typography, CardContent } from '@mui/material';

// Memoized Travel Card Component
interface TravelCardProps {
  travel: {
    travelId: number;
    startingLocation: string;
    destination: string;
    travelStatus: string;
    customer: {
      name: string;
      email: string;
    };
    createdAt: string;
  };
  onStatusChange?: (travelId: number, status: string) => void;
}

export const TravelCard = memo<TravelCardProps>(({ travel, onStatusChange }) => {
  const statusColor = useMemo(() => {
    switch (travel.travelStatus) {
      case 'COMPLETED':
        return 'success';
      case 'ON_GOING':
        return 'primary';
      case 'CANCELLED':
        return 'error';
      default:
        return 'default';
    }
  }, [travel.travelStatus]);

  const formattedDate = useMemo(() => 
    format(new Date(travel.createdAt), 'MMM dd, yyyy'), [travel.createdAt]);

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={2}>
          <Typography variant="h6" component="h3">
            {travel.startingLocation} → {travel.destination}
          </Typography>
          <Chip 
            label={travel.travelStatus} 
            color={statusColor as any}
            size="small"
          />
        </Box>
        
        <Typography variant="body2" color="text.secondary" gutterBottom>
          Customer: {travel.customer.name}
        </Typography>
        
        <Typography variant="body2" color="text.secondary" gutterBottom>
          Email: {travel.customer.email}
        </Typography>
        
        <Typography variant="caption" color="text.secondary">
          Created: {formattedDate}
        </Typography>
      </CardContent>
    </Card>
  );
});

TravelCard.displayName = 'TravelCard';

// Memoized Customer Card Component
interface CustomerCardProps {
  customer: {
    customerId: number;
    name: string;
    email: string;
    csa?: {
      name: string;
      email: string;
    };
  };
  onSelect?: (customerId: number) => void;
}

export const CustomerCard = memo<CustomerCardProps>(({ customer, onSelect }) => {
  const handleSelect = useCallback(() => {
    onSelect?.(customer.customerId);
  }, [customer.customerId, onSelect]);

  return (
    <Card 
      sx={{ 
        mb: 2, 
        cursor: onSelect ? 'pointer' : 'default',
        '&:hover': onSelect ? { bgcolor: 'action.hover' } : {}
      }}
      onClick={handleSelect}
    >
      <CardContent>
        <Typography variant="h6" component="h3" gutterBottom>
          {customer.name}
        </Typography>
        
        <Typography variant="body2" color="text.secondary" gutterBottom>
          {customer.email}
        </Typography>
        
        {customer.csa && (
          <Typography variant="caption" color="text.secondary">
            CSA: {customer.csa.name}
          </Typography>
        )}
      </CardContent>
    </Card>
  );
});

CustomerCard.displayName = 'CustomerCard';

// Memoized Feedback Card Component
interface FeedbackCardProps {
  feedback: {
    feedbackId: number;
    rating: number;
    feedback: string;
    customer: {
      name: string;
    };
    createdAt: string;
  };
}

export const FeedbackCard = memo<FeedbackCardProps>(({ feedback }) => {
  const ratingStars = useMemo(() => 
    '★'.repeat(feedback.rating) + '☆'.repeat(5 - feedback.rating), [feedback.rating]);

  const formattedDate = useMemo(() => 
    format(new Date(feedback.createdAt), 'MMM dd, yyyy'), [feedback.createdAt]);

  return (
    <Card sx={{ mb: 2 }}>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start" mb={2}>
          <Typography variant="h6" component="h3">
            {feedback.customer.name}
          </Typography>
          <Typography variant="h6" color="primary">
            {ratingStars}
          </Typography>
        </Box>
        
        <Typography variant="body2" paragraph>
          {feedback.feedback}
        </Typography>
        
        <Typography variant="caption" color="text.secondary">
          {formattedDate}
        </Typography>
      </CardContent>
    </Card>
  );
});

FeedbackCard.displayName = 'FeedbackCard';
