export interface ParticipantDeleteModalProps {
  isOpen?: boolean;
  participantFullName: string;
  onClose?(): void;
  onConfirm?(): void;
}
