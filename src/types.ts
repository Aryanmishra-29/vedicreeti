/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export interface Puja {
  id: string;
  name: string;
  description: string;
  price: number;
  durationMinutes: number;
  imageUrn: string;
  benefits: string[];
  samagriIncluded: boolean;
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PujaBooking {
  id: string;
  tenantId: string;
  pujaId: string;
  pujaName: string;
  pricePaid: number;
  userId: string;
  userName: string;
  userPhone: string;
  bookingDate: string;
  slotTime: string;
  status: 'PENDING' | 'CONFIRMED' | 'COMPLETED' | 'CANCELLED';
  createdTimestamp: string;
}

export interface AdBanner {
  id: string;
  title: string;
  imageUrl: string;
  targetLink: string;
  campaignName: string;
  active: boolean;
  impressions: number;
  clicks: number;
  startDate: string;
  endDate: string;
}

export type Role = 'DIRECTOR' | 'PUJARI' | 'SUPPORT_STAFF';

export interface UserRole {
  userId: string;
  name: string;
  email: string;
  role: Role;
  permissions: string[];
  assignedAt: string;
}

export interface ApiEndpoint {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  path: string;
  category: 'PUJAS' | 'BOOKINGS' | 'ADS' | 'RBAC';
  description: string;
  headers: Record<string, string>;
  requestBodyDescription?: string;
  exampleRequestBody?: string;
  exampleResponseBody: string;
}
