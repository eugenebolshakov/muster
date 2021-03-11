set -e

if [ "$(which docker)" ]
  then
    echo "Building docker image..."
    docker build -t muster .
    echo "Installing dependencies..."
    docker run --rm -v $PWD:/usr/src/app muster mix deps.get
    docker run --rm -v $PWD:/usr/src/app muster npm --prefix apps/muster_web/assets i
    echo "Starting the app..."
    docker run --rm -v $PWD:/usr/src/app -p 4000:4000 muster

elif [ "$(which mix)" -a "$(which npm)" ]
  then
    echo "Installing dependencies..."
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
    npm --prefix apps/muster_web/assets i
    echo "Starting the app..."
    mix phx.server
else
  echo "The app requires docker or elixir and nodejs to be installed"
  exit 1
fi
