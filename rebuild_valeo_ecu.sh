
cd buildroot/
echo "--- Starting Clean ---"
make valeo-ecu-dirclean
echo "--- Clean Done. Waiting 3 seconds... ---"
sleep 3
echo "--- Starting Build with $(nproc) cores ---"
echo "--- Delete spaces or new lines from PATH ---"
export PATH=$(echo $PATH | tr ':' '\n' | grep -v ' ' | tr '\n' ':' | sed 's/:$//') 
make -j$(nproc)
echo "--- Build Finished ---"

cd ..
