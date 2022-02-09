export interface ArtProps {
	src: string;
	alt?: string;
	title: string;
	artist?: string;
	media?: string;
	contract?: string;
}

export type Metadata = {
  name: string;
  description: string;
  attributes: string;
  image: string;
  external_url: string;
};

export type Nft = {
  path: string;
  filename: string;
  metadata: Metadata;
};
