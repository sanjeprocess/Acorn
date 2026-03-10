import {axiosInstance, axiosMultiPartInstance} from "../api/api";
import { validateSession } from "../api/ssoApi";
import type { ValidateSessionRequest } from "../api/ssoApi";

export function registerCSA(data: any) {
    return axiosInstance.post('/auth/registerCSA', data);
}

export function loginCSA(data: any) {
    return axiosInstance.post('/auth/loginCSA', data);
}
export function createNewTravel(data: any) {
    return axiosMultiPartInstance.post('/travels', data);
}

export function updateTravel(data: any) {
    return axiosMultiPartInstance.put('/travels', data);
}

export function deleteTravel(travelId: number) {
    return axiosMultiPartInstance.delete(`/travels/${travelId}`);
}

export function deleteUser(userId: number) {
    return axiosInstance.delete(`/customer/${userId}`)
}

export function validateSSOSession(data: ValidateSessionRequest) {
    return validateSession(data.cardId);
}