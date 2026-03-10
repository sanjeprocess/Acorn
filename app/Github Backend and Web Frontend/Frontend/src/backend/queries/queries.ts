import { useQuery } from "@tanstack/react-query";

import QueryKeys from "../../enums/query-keys.enum";
import { getIncidents, getCustomerFeedback, getAssignedCustomers, getCustomerTravelHistory, searchCustomers } from "./queryFns";

export function useGetAssignedCustomers(csaId: string, options?: { enabled?: boolean }) {
    return useQuery({
        queryKey: [QueryKeys.Customers],
        queryFn: () => getAssignedCustomers(csaId),
        enabled: options?.enabled !== false && !!csaId,
    });
}

export function useSearchCustomers(csaId: string, searchQuery: string, enabled: boolean = true) {
    return useQuery({
        queryKey: [QueryKeys.Customers, 'search', searchQuery],
        queryFn: () => searchCustomers(csaId, searchQuery),
        enabled: enabled && !!csaId && searchQuery.trim().length > 0,
    });
}

export function useGetCustomerFeedback() {
    return useQuery({
        queryKey: [QueryKeys.Feedback],
        queryFn: () => getCustomerFeedback(),
    });
}

export function useGetAllIncidents() {
    return useQuery({
        queryKey: [QueryKeys.Incidents],
        queryFn: () => getIncidents(),
    });
}
export function useGetPastTravels(customerId: string) {
    return useQuery({
        queryKey: [QueryKeys.TravelHistory],
        queryFn: () => getCustomerTravelHistory(customerId),
        enabled: !!customerId,
    });
}