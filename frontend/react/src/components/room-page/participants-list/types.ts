import type { GetParticipantsResponse, Participant } from "@types/api.ts";

export interface ParticipantsListProps {
  participants: GetParticipantsResponse;
  onDeleteParticipant?(participant: Participant): void;
  isRoomClosed?: boolean;
}

export interface PersonalInformation {
  firstName: string;
  lastName: string;
  phone: string;
  email?: string;
  deliveryInfo: string;
  link?: string;
}
