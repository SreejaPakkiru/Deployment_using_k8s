# FROM node:14.17.3-alpine3.14

# WORKDIR /usr/src/app

# COPY package.json package-lock.json ./
# RUN npm ci
# COPY ./server.js ./

# CMD ["npm","start"]
#Build Stage
# FROM node:18-alpine AS build

# WORKDIR /usr/src/app

# COPY package.json package-lock.json ./

# RUN npm ci --omit=dev

# COPY . .

# #Production Stage
# FROM node:18-alpine

# WORKDIR /usr/src/app

# COPY --from=build /usr/src/app /usr/src/app

# # Copy tests folder
# COPY ./tests/smoke-test.sh /tests
# WORKDIR /tests
# RUN chmod +x ./tests/smoke-test.sh

# # Run tests first, then start app
# CMD ["sh", "-c", "./tests/smoke-test.sh && cd /usr/src/app && npm start"]
#Build Stage
FROM node:18-alpine AS build

WORKDIR /usr/src/app

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

COPY . .

#Production Stage
FROM node:18-alpine

WORKDIR /usr/src/app

COPY --from=build /usr/src/app /usr/src/app

CMD ["npm", "start"]
