import { useMutation } from "@tanstack/react-query"; 

import MutationKeys from "../../enums/mutation-keys.enum";
import { loginCSA, deleteUser, registerCSA, updateTravel, deleteTravel, createNewTravel, validateSSOSession } from "./mutationFns";

export function useRegisterCSA() {
    return useMutation({
        mutationKey: [MutationKeys.RegisterCSA],
        mutationFn: (data: any) => registerCSA(data),
    });
}
export function useLogInCSA() {
    return useMutation({
        mutationKey: [MutationKeys.LogInCSA],
        mutationFn: (data: any) => loginCSA(data),
    });
}
export function useNewTravel() {
    return useMutation({
        mutationKey: [MutationKeys.Travels],
        mutationFn: (data: any) => createNewTravel(data),
    });
}
export function useDeleteUser() {
    return useMutation({
        mutationKey: [MutationKeys.Users],
        mutationFn: (data: any) => deleteUser(data),
    });
}

export function useUpdateTravel() {
    return useMutation({
        mutationKey: [MutationKeys.Travels],
        mutationFn: (data: any) => updateTravel(data),
    });
}

export function useDeleteTravel() {
    return useMutation({
        mutationKey: [MutationKeys.Travels],
        mutationFn: (travelId: number) => deleteTravel(travelId),
    });
}

export function useValidateSSOSession() {
    return useMutation({
        mutationKey: [MutationKeys.SSOValidation],
        mutationFn: (data: any) => validateSSOSession(data),
    });
}