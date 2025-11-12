import CopyButton from "../copy-button/CopyButton";
import InfoButton from "../info-button/InfoButton";
import ItemCard from "../item-card/ItemCard";
import { type ParticipantCardProps } from "./types";
import "./ParticipantCard.scss";
import DeleteButton from "@components/common/delete-button/DeleteButton.tsx";
import ParticipantDeleteModal from "@components/common/modals/participant-delete-modal/ParticipantDeleteModal.tsx";
import { useState } from "react";

const ParticipantCard = ({
  firstName,
  lastName,
  isCurrentUser = false,
  isAdmin = false,
  isCurrentUserAdmin = false,
  adminInfo = "",
  participantLink = "",
  onInfoButtonClick,
  onDeleteButtonClick,
  isRoomClosed = false,
}: ParticipantCardProps) => {
  const [isParticipantDeleteModalOpened, setIsParticipantDeleteModalOpened] =
    useState<boolean>(false);

  const handleDeleteParticipantButtonClick = () => {
    setIsParticipantDeleteModalOpened(true);
  };

  const handleConfirmDeleteParticipantButtonClick = () => {
    onDeleteButtonClick?.();
    setIsParticipantDeleteModalOpened(false);
  };

  return (
    <div>
      <ItemCard title={`${firstName} ${lastName}`} isFocusable>
        <div className="participant-card-info-container">
          {isCurrentUser ? <p className="participant-card-role">You</p> : null}

          {!isCurrentUser && isAdmin ? (
            <p className="participant-card-role">Admin</p>
          ) : null}

          {isCurrentUserAdmin ? (
            <CopyButton
              textToCopy={participantLink}
              iconName="link"
              successMessage="Personal Link is copied!"
              errorMessage="Personal Link was not copied. Try again."
            />
          ) : null}

          {isCurrentUserAdmin && !isAdmin ? (
            <InfoButton withoutToaster onClick={onInfoButtonClick} />
          ) : null}

          {!isCurrentUser && isAdmin ? (
            <InfoButton infoMessage={adminInfo} />
          ) : null}

          {!isRoomClosed && isCurrentUserAdmin && !isAdmin ? (
            <DeleteButton onClick={handleDeleteParticipantButtonClick} />
          ) : null}
        </div>
      </ItemCard>
      <ParticipantDeleteModal
        isOpen={isParticipantDeleteModalOpened}
        participantFullName={`${firstName} ${lastName}`}
        onClose={() => setIsParticipantDeleteModalOpened(false)}
        onConfirm={handleConfirmDeleteParticipantButtonClick}
      />
    </div>
  );
};

export default ParticipantCard;
