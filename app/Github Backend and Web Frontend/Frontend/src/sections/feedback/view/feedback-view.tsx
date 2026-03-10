



import { DashboardContent } from 'src/layouts/dashboard';

import { FeedBackTable } from '../../overview/feed-back-table';
import { useGetCustomerFeedback } from '../../../backend/queries/queries';


// ----------------------------------------------------------------------

export function FeedbackView() {

    const {data: feedbackRes, isLoading} = useGetCustomerFeedback()
  
  return (
    <DashboardContent>
      <FeedBackTable title="Customer Reviews" list={feedbackRes?.data.data.feedbacks} isLoading={isLoading} />
    </DashboardContent>
  );
}
