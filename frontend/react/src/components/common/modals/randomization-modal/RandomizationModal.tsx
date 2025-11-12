import { useEffect } from "react";
import { createPortal } from "react-dom";
import IconButton from "@components/common/icon-button/IconButton";
import Button from "@components/common/button/Button";
import Wishlist from "@components/common/wishlist/Wishlist";
import PersonalInformation from "@components/common/personal-information/PersonalInformation";
import type { RandomizationModalProps } from "./types";
import "@assets/styles/common/modal-container.scss";
import "./RandomizationModal.scss";

const RandomizationModal = ({
  isOpen = false,
  onClose,
  personalInfoData,
  wishlistData,
}: RandomizationModalProps) => {
  useEffect(() => {
    document.body.style.overflow = isOpen ? "hidden" : "";

    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  const randomizationModalElement = (
    <div className="modal-container">
      <div className="randomization-modal">
        <h3 className="randomization-modal__title">Look Who You Got!</h3>

        <div className="randomization-modal__close-button">
          <IconButton iconName="cross" onClick={onClose} />
        </div>

        <div className="randomization-modal__content">
          {personalInfoData ? (
            <PersonalInformation
              {...personalInfoData}
              withBackground
              isOneColumn
            />
          ) : null}

          {wishlistData ? <Wishlist {...wishlistData} withAiHelp /> : null}
        </div>

        <div className="randomization-modal__back-button">
          <Button width={228} size="medium" onClick={onClose}>
            Go Back to Room
          </Button>
        </div>
      </div>
    </div>
  );

  return createPortal(randomizationModalElement, document.body);
};

export default RandomizationModal;
