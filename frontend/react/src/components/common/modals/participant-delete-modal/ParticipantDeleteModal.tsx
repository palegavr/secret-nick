import Modal from "@components/common/modals/modal/Modal.tsx";
import "./ParticipantDeleteModal.scss";
import type { ParticipantDeleteModalProps } from "@components/common/modals/participant-delete-modal/types.ts";

export default function ParticipantDeleteModal({
  isOpen = false,
  participantFullName,
  onClose = () => {},
  onConfirm = () => {},
}: ParticipantDeleteModalProps) {
  return (
    <Modal
      isOpen={isOpen}
      title="Delete participant"
      description=""
      iconName="action-card-bg"
      confirmButtonText="Confirm"
      onClose={onClose}
      onConfirm={onConfirm}
    >
      <p className="participant-delete-modal__content">
        Are you sure you want to remove{" "}
        <span className="participant-delete-modal__content__participant-full-name">
          {participantFullName}
        </span>
        ?
      </p>
    </Modal>
  );
}
