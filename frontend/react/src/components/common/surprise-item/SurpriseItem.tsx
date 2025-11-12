import type { SurpriseItemProps } from "./types";
import "./SurpriseItem.scss";
import Button from "@components/common/button/Button.tsx";
import { BASE_API_URL } from "@utils/general.ts";
import { useState } from "react";

const SurpriseItem = ({ text, withAiHelp = false }: SurpriseItemProps) => {
  const [aiProposals, setAiProposals] = useState<string>("");
  const [aiProposalsLoading, setAiProposalsLoading] = useState<boolean>(false);

  async function handleClickGenerateIdeasForGiftButton() {
    setAiProposalsLoading(true);
    try {
      const response = await fetch(
        `${BASE_API_URL}/api/ai/generate-ideas-for-gift`,
        {
          body: JSON.stringify({
            interests: text,
          }),
          method: "POST",
          headers: { "Content-Type": "application/json" },
        },
      );

      if (response.status === 200) {
        const body: { ideasForGift: string } = await response.json();
        setAiProposals(body.ideasForGift);
      } else {
        setAiProposals("Error, try again.");
      }
    } catch {
      setAiProposals("Error, try again.");
    } finally {
      setAiProposalsLoading(false);
    }
  }

  return (
    <div className="surprise-item">
      <p className="surprise-item__title">Surprise me!</p>
      {text ? <p className="surprise-item__description">{text}</p> : null}
      {aiProposalsLoading ? (
        <p className="surprise-item__ai_thinking_text">Thinking...</p>
      ) : (
        <>
          {aiProposals && (
            <p className="surprise-item__ai_proposals">
              <span className="surprise-item__ai_proposals__title">
                AI proposals:{" "}
              </span>
              <span className="surprise-item__ai_proposals__content">
                {aiProposals}
              </span>
            </p>
          )}
        </>
      )}

      {withAiHelp && (
        <Button
          style={{ width: "auto", marginTop: "24px" }}
          variant="secondary"
          size="small"
          disabled={aiProposalsLoading}
          onClick={handleClickGenerateIdeasForGiftButton}
        >
          Ask AI to help you choose a gift
        </Button>
      )}
    </div>
  );
};

export default SurpriseItem;
