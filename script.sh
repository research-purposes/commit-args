if [ -n "$1" ]; then
    GITHUB_TOKEN="$1"
fi
if [ -n "$2" ]; then
    REPO="$2"
fi
if [ -n "$3" ]; then
    ACTION_ID="$3"
fi

github_action_list() {
  REPO=`git remote -v show | awk 'NR==1 {print $2}' | sed 's/git@github.com://' | sed 's/\.git$//'`
  curl --header "Authorization: token $GITHUB_TOKEN" -L "https://api.github.com/repos/$REPO/actions/runs" \
   | jq ".workflow_runs[] | {id: .id, message: .head_commit.message, event: .event, status: .status, conclusion: .conclusion} " -C \
   | less -R
}

github_action_view() {
  TMPFILE=`mktemp`
  TMPDIR=`mktemp -d`
  ONEFILE=`mktemp`

  if [ -z "${1-}" ]
  then
    echo 'github_action_view ACTION_ID'
    return
  fi

  REPO=`git remote -v show | awk 'NR==1 {print $2}' | sed 's/git@github.com://' | sed 's/\.git$//'`
  ACTION_ID=$1
  curl --header "Authorization: token $GITHUB_TOKEN" \
  -L "https://api.github.com/repos/$REPO/actions/runs/$ACTION_ID/logs" \
  -o "$TMPFILE"
  unzip -d "$TMPDIR" "$TMPFILE"

  FILES=$(find "$TMPDIR" -type f)
  for f in $FILES
  do
    echo "\033[0;31m----------------------------------------------\033[0m" >> $ONEFILE
    echo "$f" >> $ONEFILE
    echo "\033[0;31m----------------------------------------------\033[0m" >> $ONEFILE
    cat "$f" >> $ONEFILE
  done

  cat $ONEFILE | less -R
}
