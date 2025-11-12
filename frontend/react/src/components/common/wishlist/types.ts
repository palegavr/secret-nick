import type { WishList } from "@types/api";

interface WishlistBaseProps {
  width?: string;
  withoutHeader?: boolean;
  withAiHelp?: boolean;
}

interface WishlistListProps extends WishlistBaseProps {
  variant: "wishlist";
  wishList: WishList;
}

interface WishlistSurpriseProps extends WishlistBaseProps {
  variant: "surprise";
  interests?: string;
}

export type WishlistProps = WishlistListProps | WishlistSurpriseProps;
