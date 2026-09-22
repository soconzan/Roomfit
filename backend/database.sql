create table categories (
	category_id bigserial primary key,
	category_name text not null,
    embedding vector(768)
);

create table users (
	user_id uuid primary key,
	nickname text not null,
	username text not null,
	password text not null,
	image_url text not null 
);

create table products (
	product_id bigserial primary key,
	user_id uuid not null,
	category_id bigserial not null,
	product_name text not null,
	product_price bigint not null,
	description text not null,
	created_at TIMESTAMPTZ not null default current_timestamp,
	updated_at TIMESTAMPTZ not null default current_timestamp,
	style text,
	image_embedding vector(768),
	color_vector_1 vector(3),
	color_vector_2 vector(3),
	color_vector_3 vector(3),
	product_width float,
	product_depth float,
	product_height float,
	product_material text,
    product_image_front_url text,
    product_image_back_url text,
    product_image_left_url text,
    product_image_right_url text,
	model_url text,
	vision_status text default 'PENDING',
	vision_retry_count integer default 0,
	vision_last_attempt_at TIMESTAMPTZ,
	vision_error_message text,
	constraint fk_user_product
		foreign key (user_id)
		references public.users(user_id)
		on delete set null,
	constraint fk_category_product
		foreign key (category_id)
		references public.categories(category_id)
		on delete set null
);

create table imagefiles (
	image_id bigserial primary key,
	product_id bigserial not null,
	image_url text not null,
	constraint fk_product_imagefile
		foreign key (product_id) 
		references public.products(product_id) 
		on delete set null
);

create table fcm_tokens (
    token_id bigserial primary key,
    user_id uuid not null,
    fcm_token text not null,
    constraint fk_user_fcm_token
        foreign key (user_id)
        references public.users(user_id)
        on delete set null
);

create index products_image_embedding_hnsw on products using hnsw (image_embedding vector_cosine_ops);
create index color_vector_1_hnsw on products using hnsw (color_vector_1 vector_l2_ops);
create index color_vector_2_hnsw on products using hnsw (color_vector_2 vector_l2_ops);
create index color_vector_3_hnsw on products using hnsw (color_vector_3 vector_l2_ops);
create index categories_embedding_hnsw on categories using hnsw (embedding vector_cosine_ops);